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

echo "1. Testing encryption..."
# Create test data in current directory since CI has already set it up
if [ ! -f "data/config/master.cnf" ]; then
    echo "❌ Test data not found - integration test needs data/ directory"
    exit 1
fi

# Test encryption with -pass for automation
echo "# encrypt data"  
tar -czf data.tar.gz data/ > /dev/null
openssl aes256 -pbkdf2 -salt -in data.tar.gz -out test-data.aes256 -pass pass:test-password-123
rm data.tar.gz
echo "✅ Encryption successful"

echo ""
echo "2. Testing decryption..."
# Remove original data to test decryption
rm -rf data/

# Decrypt the test data  
cd "$TEST_DIR"
openssl enc -d -aes256 -pbkdf2 -salt -in "$BASE_PATH/test-data.aes256" -out test-data.tar.gz -pass pass:test-password-123

if [ ! -f "test-data.tar.gz" ]; then
    echo "❌ Decryption failed"
    exit 1
fi

tar -xzf test-data.tar.gz
mv data test-data

if [ ! -f "test-data/config/master.cnf" ]; then
    echo "❌ Decryption failed - config not found"
    exit 1
fi
echo "✅ Decryption successful"

echo ""
echo "3. Testing recipe system..."
# Test that recipes script can be run in dry mode
export DRY_RUN=true

# Create a minimal test that just checks recipe loading
cat > "$TEST_DIR/test-recipe-loading.sh" << 'EOF'
#!/usr/bin/env bash
set -e

BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
RECIPES_CONFIG="$BASE_PATH/recipes.yaml"

# Install yq if needed
if ! command -v yq &> /dev/null; then
    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 2>/dev/null
    sudo chmod +x /usr/local/bin/yq
fi

# Test loading all recipes
recipes=$(yq '.recipes[].name' "$RECIPES_CONFIG")
recipe_count=$(echo "$recipes" | wc -l)

echo "Found $recipe_count recipes"

# Test each recipe exists
missing_scripts=""
for i in $(seq 0 30); do
    recipe_name=$(yq ".recipes[$i].name" "$RECIPES_CONFIG" 2>/dev/null | sed 's/"//g')
    if [ "$recipe_name" != "null" ] && [ ! -z "$recipe_name" ]; then
        script=$(yq ".recipes[$i].script" "$RECIPES_CONFIG" | sed 's/"//g')
        if [ ! -f "$BASE_PATH/recipes/$script" ]; then
            missing_scripts="$missing_scripts $script"
        fi
    fi
done

if [ ! -z "$missing_scripts" ]; then
    echo "❌ Recipe scripts missing:$missing_scripts"
    exit 1
fi

echo "✅ All recipe scripts found"
EOF

chmod +x "$TEST_DIR/test-recipe-loading.sh"
"$TEST_DIR/test-recipe-loading.sh"

echo ""
echo "4. Testing Docker build for sample recipes..."
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
echo "5. Testing update mechanism..."
# Create a mock update test
cat > "$TEST_DIR/test-update.sh" << 'EOF'
#!/usr/bin/env bash
# Simple test to verify refresh script exists and has correct structure
BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
REFRESH_SCRIPT="$BASE_PATH/refresh"

if [ -f "$REFRESH_SCRIPT" ] && [ -x "$REFRESH_SCRIPT" ]; then
    echo "✅ Refresh script exists and is executable"
else
    echo "❌ Refresh script missing or not executable"
    if [ -f "$REFRESH_SCRIPT" ]; then
        echo "Debug: refresh exists but not executable, permissions:"
        ls -la "$REFRESH_SCRIPT"
    else
        echo "Debug: refresh file does not exist at: $REFRESH_SCRIPT"
    fi
    exit 1
fi
EOF

chmod +x "$TEST_DIR/test-update.sh"
"$TEST_DIR/test-update.sh"

# Cleanup
rm -rf "$TEST_DIR"
rm -f "$BASE_PATH/test-data.aes256"

echo ""
echo "==================================="
echo "✅ All integration tests passed!"
echo "==================================="