#!/usr/bin/env bash

# Integration test for the complete resetup process

set -e

echo "=== Resetup Integration Test ==="
echo ""

BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
TEST_DIR="$BASE_PATH/.integration-test"
TESTS_DIR="$BASE_PATH/tests"

# Clean up any previous test
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

echo "1. Creating test data..."
# Create test machine directory structure
mkdir -p "$TEST_DIR/machines/test-machine"
mkdir -p "$TEST_DIR/machines/test-machine/files/.ssh"

# Create test master.cnf
cat > "$TEST_DIR/machines/test-machine/master.cnf" << 'EOF'
#!/usr/bin/env bash
# Test configuration
export GIT_USERNAME="Test User"
export GIT_EMAIL="test@example.com"
export GITHUB_TOKEN="test-token"
export EDITOR="vim"
EOF

# Create test cookbook.yaml
cat > "$TEST_DIR/machines/test-machine/cookbook.yaml" << 'EOF'
recipes:
  - base
  - git
EOF

# Create test SSH config
cat > "$TEST_DIR/machines/test-machine/files/.ssh/config" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa
EOF

echo "✅ Test data created"

echo ""
echo "2. Testing encryption..."
# Test encryption with -pass for automation
echo "# encrypt test machine data"  
cd "$TEST_DIR"
tar -czf test-machine.tar.gz machines/test-machine/ > /dev/null
openssl aes256 -pbkdf2 -salt -in test-machine.tar.gz -out machines/test-machine.aes256 -pass pass:test-password-123
rm test-machine.tar.gz
echo "✅ Encryption successful"

echo ""
echo "3. Testing decryption..."
# Remove original data to test decryption
rm -rf machines/test-machine/

# Decrypt the test data  
openssl enc -d -aes256 -pbkdf2 -salt -in machines/test-machine.aes256 -out test-machine.tar.gz -pass pass:test-password-123

if [ ! -f "test-machine.tar.gz" ]; then
    echo "❌ Decryption failed"
    exit 1
fi

tar -xzf test-machine.tar.gz

if [ ! -f "machines/test-machine/master.cnf" ]; then
    echo "❌ Decryption failed - config not found"
    exit 1
fi
echo "✅ Decryption successful"

echo ""
echo "4. Testing recipe system..."
# Test that recipes script can be run in dry mode
export DRY_RUN=true

# Create a minimal test that just checks recipe loading
cat > "$TEST_DIR/test-recipe-loading.sh" << 'EOF'
#!/usr/bin/env bash
set -e

BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
RECIPES_CONFIG="$BASE_PATH/recipes.yaml"

# Test loading all recipes using Python
missing_scripts=""
recipe_count=$(python3 -c "
import yaml
with open('$RECIPES_CONFIG', 'r') as f:
    data = yaml.safe_load(f)
print(len(data['recipes']))
")

echo "Found $recipe_count recipes"

# Test each recipe exists
missing_scripts=$(python3 -c "
import yaml
import os

with open('$RECIPES_CONFIG', 'r') as f:
    data = yaml.safe_load(f)

missing = []
for recipe in data['recipes']:
    script_path = '$BASE_PATH/recipes/' + recipe['script']
    if not os.path.exists(script_path):
        missing.append(recipe['script'])

if missing:
    print(' '.join(missing))
")

if [ ! -z "$missing_scripts" ]; then
    echo "❌ Recipe scripts missing:$missing_scripts"
    exit 1
fi

echo "✅ All recipe scripts found"
EOF

chmod +x "$TEST_DIR/test-recipe-loading.sh"
"$TEST_DIR/test-recipe-loading.sh"

echo ""
echo "5. Testing Docker build for sample recipes..."
# Skip Docker recipe testing in CI environment (requires Docker-in-Docker)
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    echo "  Skipping Docker recipe tests in CI environment"
    echo "  ✅ (Docker recipe testing requires Docker-in-Docker setup)"
else
    # Test a few key recipes locally
    for recipe in base git ripgrep; do
        echo -n "  Testing $recipe... "
        if ./tests/test-recipe.sh "$recipe" > /dev/null 2>&1; then
            echo "✅"
        else
            echo "❌"
            exit 1
        fi
    done
fi

echo ""
echo "6. Testing unified resetup command..."
# Test that resetup command exists and works
if [ -f "$BASE_PATH/resetup" ] && [ -x "$BASE_PATH/resetup" ]; then
    echo "✅ Resetup command exists and is executable"
    
    # Test help command
    if "$BASE_PATH/resetup" help > /dev/null 2>&1; then
        echo "✅ Resetup help command works"
    else
        echo "❌ Resetup help command failed"
        exit 1
    fi
else
    echo "❌ Resetup command missing or not executable"
    exit 1
fi

echo ""
echo "7. Testing script locations..."
# Test that all scripts exist in scripts/ directory
for script in init pack unpack clean refresh recipes; do
    if [ -f "$BASE_PATH/scripts/$script" ] && [ -x "$BASE_PATH/scripts/$script" ]; then
        echo "✅ Script $script exists in scripts/ directory"
    else
        echo "❌ Script $script missing or not executable in scripts/ directory"
        exit 1
    fi
done

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "==================================="
echo "✅ All integration tests passed!"
echo "==================================="