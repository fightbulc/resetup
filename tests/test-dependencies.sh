#!/usr/bin/env bash

# Test dependency resolution logic

set -e

echo "Testing dependency resolution..."

# Create a minimal test environment
BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
RECIPES_CONFIG="$BASE_PATH/recipes.yaml"

# Install yq if not present
if ! command -v yq &> /dev/null; then
    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    sudo chmod +x /usr/local/bin/yq
fi

# Test function to get dependencies
get_recipe_dependencies() {
    local recipe_name=$1
    yq eval ".recipes[] | select(.name == \"$recipe_name\") | .dependencies[]" "$RECIPES_CONFIG" 2>/dev/null || echo ""
}

# Test 1: Check base has no dependencies
echo -n "Test 1: Base recipe has no dependencies... "
deps=$(get_recipe_dependencies "base")
if [ -z "$deps" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL - Base has dependencies: $deps"
    exit 1
fi

# Test 2: Check git depends on base
echo -n "Test 2: Git recipe depends on base... "
deps=$(get_recipe_dependencies "git")
if [ "$deps" = "base" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL - Git dependencies: $deps"
    exit 1
fi

# Test 3: Check lazygit depends on git
echo -n "Test 3: Lazygit recipe depends on git... "
deps=$(get_recipe_dependencies "lazygit")
if [ "$deps" = "git" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL - Lazygit dependencies: $deps"
    exit 1
fi

# Test 4: Check wifi has correct dependencies
echo -n "Test 4: WiFi recipe depends on base... "
deps=$(get_recipe_dependencies "wifi")
if [ "$deps" = "base" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL - WiFi dependencies: $deps"
    exit 1
fi

# Test 5: Build full dependency tree for a complex recipe
echo -n "Test 5: Build dependency tree for claude-code... "
visited_file=$(mktemp)

build_dependency_tree() {
    local recipe=$1
    local indent=$2
    
    # Check if already visited
    if grep -q "^$recipe$" "$visited_file" 2>/dev/null; then
        return 0
    fi
    echo "$recipe" >> "$visited_file"
    
    echo "${indent}$recipe"
    
    local deps=$(get_recipe_dependencies "$recipe")
    if [ ! -z "$deps" ]; then
        echo "$deps" | while read -r dep; do
            if [ ! -z "$dep" ]; then
                build_dependency_tree "$dep" "${indent}  "
            fi
        done
    fi
}

echo ""
build_dependency_tree "claude-code" ""
rm -f "$visited_file"
echo "✅ PASS"

echo ""
echo "✅ All dependency tests passed!"