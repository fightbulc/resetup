#!/usr/bin/env bash

# Run tests locally exactly as they run in GitHub Actions CI
# This ensures local tests match CI behavior precisely

set -e

echo "=== Running Tests Locally (GitHub Actions Style) ==="
echo ""

BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
cd "$BASE_PATH"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
JOBS_PASSED=0
JOBS_FAILED=0

run_job() {
    local job_name=$1
    local job_function=$2
    
    echo -e "${YELLOW}=== JOB: $job_name ===${NC}"
    if $job_function; then
        echo -e "${GREEN}✅ JOB PASSED: $job_name${NC}"
        ((JOBS_PASSED++))
    else
        echo -e "${RED}❌ JOB FAILED: $job_name${NC}"
        ((JOBS_FAILED++))
    fi
    echo ""
}

# Job 1: validate-yaml (matches CI exactly)
validate_yaml() {
    echo "Step: Validate recipes.yaml"
    python3 -c "import yaml; yaml.safe_load(open('recipes.yaml')); print('✅ recipes.yaml is valid')"
    
    echo "Step: Check recipe files exist"
    echo "Checking all recipe files exist..."
    python3 -c "
import yaml, os
data = yaml.safe_load(open('recipes.yaml'))
missing = []
for recipe in data['recipes']:
    script_path = 'recipes/' + recipe['script']
    if not os.path.exists(script_path):
        missing.append(script_path)
        print(f'❌ Missing: {script_path}')
    else:
        print(f'✓ Found: {script_path}')
if missing: exit(1)
else: print('✅ All recipe files exist')
"
}

# Job 2: test-recipes (dynamically reads all existing recipes)
test_recipes() {
    # Skip recipe testing in CI mode
    if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
        echo "Skipping Docker recipe tests in CI environment"
        echo "✅ (Docker recipe testing requires Docker-in-Docker setup)"
        return 0
    fi
    
    echo "Step: Reading recipes from recipes.yaml"
    local recipes=()
    while IFS= read -r recipe; do
        recipes+=("$recipe")
    done < <(yq eval '.recipes[].name' recipes.yaml)
    
    echo "Found ${#recipes[@]} recipes to test: ${recipes[*]}"
    
    echo "Step: Set up Docker (checking Docker is available)"
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not available - skipping recipe tests"
        return 1
    fi
    
    echo "Step: Create test machine directory"
    # Create test machine structure in tests directory
    mkdir -p tests/.run-all-tests/machines/test-machine/files/.ssh
    cp -r machines/.gitkeep tests/.run-all-tests/machines/ 2>/dev/null || true
    
    # Create test master.cnf
    cat > tests/.run-all-tests/machines/test-machine/master.cnf << 'EOF'
#!/usr/bin/env bash
export GIT_USERNAME="Test User"
export GIT_EMAIL="test@example.com"
EOF
    
    # Create test cookbook.yaml
    cat > tests/.run-all-tests/machines/test-machine/cookbook.yaml << 'EOF'
recipes:
  - base
  - git
EOF
    
    local failed_recipes=()
    
    for recipe in "${recipes[@]}"; do
        echo "Step: Test recipe - $recipe"
        chmod +x tests/test-recipe.sh
        if ./tests/test-recipe.sh "$recipe"; then
            echo "✅ Recipe test passed: $recipe"
        else
            echo "❌ Recipe test failed: $recipe"
            failed_recipes+=("$recipe")
        fi
    done
    
    if [ ${#failed_recipes[@]} -gt 0 ]; then
        echo "❌ Failed recipes: ${failed_recipes[*]}"
        return 1
    fi
    
    return 0
}

# Job 3: test-encryption (updated for machine-only architecture) 
test_encryption() {
    echo "Step: Create test machine data"
    # Create test machine structure in tests directory
    mkdir -p tests/.run-all-tests/machines/test-machine/files/.ssh
    
    # Create test master.cnf
    cat > tests/.run-all-tests/machines/test-machine/master.cnf << 'EOF'
#!/usr/bin/env bash
export GIT_USERNAME="Test User"
export GIT_EMAIL="test@example.com"
EOF
    
    # Create test cookbook.yaml
    cat > tests/.run-all-tests/machines/test-machine/cookbook.yaml << 'EOF'
recipes:
  - base
  - git
EOF
    
    # Add additional test files
    echo "test-key" > tests/.run-all-tests/machines/test-machine/files/.ssh/test_key
    
    echo "Step: Test encryption/decryption"
    
    # Test encryption using direct openssl (mimic pack command)
    echo "# encrypt machine data"
    cd tests/.run-all-tests
    tar -czf test-machine.tar.gz machines/test-machine/ > /dev/null
    openssl aes256 -pbkdf2 -salt -in test-machine.tar.gz -out machines/test-machine.aes256 -pass pass:test-password
    cd ../..
    rm test-machine.tar.gz
    echo "✅ Encryption successful"
    
    # Verify encrypted file exists
    if [ ! -f "tests/.run-all-tests/machines/test-machine.aes256" ]; then
        echo "❌ Encryption failed - machines/test-machine.aes256 not found"
        return 1
    fi
    
    # Remove original machine data
    rm -rf tests/.run-all-tests/machines/test-machine/
    
    # Test decryption using direct openssl (mimic dec command)
    cd tests/.run-all-tests
    openssl enc -d -aes256 -pbkdf2 -salt -in machines/test-machine.aes256 -out test-machine.tar.gz -pass pass:test-password
    tar -xzf test-machine.tar.gz
    rm test-machine.tar.gz
    cd ../..
    
    # Verify decryption
    if [ ! -f "tests/.run-all-tests/machines/test-machine/master.cnf" ]; then
        echo "❌ Decryption failed"
        return 1
    fi
    
    echo "✅ Encryption/decryption test passed"
}

# Job 4: test-dependencies (matches CI exactly)
test_dependencies() {
    echo "Step: Check circular dependencies"
    python3 tests/check-dependencies.py
    
    echo "Step: Test dependency resolution"
    chmod +x tests/test-dependencies.sh
    ./tests/test-dependencies.sh
}

# Job 5: integration-test (matches CI exactly)
integration_test() {
    echo "Step: Run integration test"
    chmod +x tests/integration-test.sh
    CI=true ./tests/integration-test.sh
}

# Clean up any existing test artifacts
echo "Cleaning up any existing test artifacts..."
rm -rf tests/.run-all-tests/ tests/.integration-test/ tests/.test/

# Run all jobs (matching GitHub Actions job order)
run_job "validate-yaml" validate_yaml
run_job "test-recipes" test_recipes  
run_job "test-encryption" test_encryption
run_job "test-dependencies" test_dependencies
run_job "integration-test" integration_test

# Clean up after tests
echo "Cleaning up test artifacts..."
rm -rf tests/.run-all-tests/ tests/.integration-test/ tests/.test/

# Summary (matches GitHub Actions style)
echo "==================================="
echo "CI-Style Test Summary:"
echo "  Jobs Passed: $JOBS_PASSED"
echo "  Jobs Failed: $JOBS_FAILED"
echo ""

if [ $JOBS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All CI jobs passed locally!${NC}"
    echo "Tests should pass in GitHub Actions"
    exit 0
else
    echo -e "${RED}❌ Some CI jobs failed locally${NC}"
    echo "These failures will likely occur in GitHub Actions too"
    exit 1
fi