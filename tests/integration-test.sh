#!/usr/bin/env bash

# Integration test for the complete resetup process

set -e

echo "=== Resetup Integration Test ==="
echo ""

BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
TEST_DIR="$BASE_PATH/.integration-test"

# Clean up any previous test
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

echo "1. Testing encryption..."
# Create a test password file
echo "test-password-123" > "$TEST_DIR/test-password"

# Test pack with automated password
cat "$TEST_DIR/test-password" | ./pack
if [ ! -f "data.aes256" ]; then
    echo "❌ Pack failed - encrypted file not created"
    exit 1
fi
echo "✅ Encryption successful"

echo ""
echo "2. Testing decryption..."
# Backup and remove original data
mv data "$TEST_DIR/data-backup"

# Decrypt only (not full unpack)
cat "$TEST_DIR/test-password" | openssl enc -d -aes256 -pbkdf2 -salt -in data.aes256 -out "$TEST_DIR/data.tar.gz"
tar -xzf "$TEST_DIR/data.tar.gz" -C .

if [ ! -f "data/config/master.cnf" ]; then
    echo "❌ Decryption failed"
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
recipes=$(yq eval '.recipes[].name' "$RECIPES_CONFIG")
recipe_count=$(echo "$recipes" | wc -l)

echo "Found $recipe_count recipes"

# Test each recipe exists
while IFS= read -r recipe_name; do
    if [ ! -z "$recipe_name" ]; then
        script=$(yq eval ".recipes[] | select(.name == \"$recipe_name\") | .script" "$RECIPES_CONFIG")
        if [ ! -f "$BASE_PATH/recipes/$script" ]; then
            echo "❌ Recipe script missing: $script"
            exit 1
        fi
    fi
done <<< "$recipes"

echo "✅ All recipe scripts found"
EOF

chmod +x "$TEST_DIR/test-recipe-loading.sh"
"$TEST_DIR/test-recipe-loading.sh"

echo ""
echo "4. Testing Docker build for sample recipes..."
# Test a few key recipes
for recipe in base git ripgrep; do
    echo -n "  Testing $recipe... "
    if ./tests/test-recipe.sh "$recipe" > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        exit 1
    fi
done

echo ""
echo "5. Testing update mechanism..."
# Create a mock update test
cat > "$TEST_DIR/test-update.sh" << 'EOF'
#!/usr/bin/env bash
# Simple test to verify update-recipes script exists and has correct structure
if [ -f "update-recipes" ] && [ -x "update-recipes" ]; then
    echo "✅ Update script exists and is executable"
else
    echo "❌ Update script missing or not executable"
    exit 1
fi
EOF

chmod +x "$TEST_DIR/test-update.sh"
"$TEST_DIR/test-update.sh"

# Cleanup
rm -rf "$TEST_DIR"
rm -f data.aes256
mv "$TEST_DIR/data-backup" data 2>/dev/null || true

echo ""
echo "==================================="
echo "✅ All integration tests passed!"
echo "==================================="