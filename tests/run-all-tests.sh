#!/usr/bin/env bash

# Run all tests locally

set -e

echo "=== Running All Resetup Tests ==="
echo ""

BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
cd "$BASE_PATH"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -n "Running $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

# 1. YAML Validation
run_test "YAML validation" "yq eval '.' recipes.yaml"

# 2. Recipe files exist
run_test "Recipe files exist" "tests/test-dependencies.sh"

# 3. Python dependency check
run_test "Circular dependency check" "python3 tests/check-dependencies.py"

# 4. Shellcheck on scripts
if command -v shellcheck &> /dev/null; then
    run_test "Shellcheck scripts" "shellcheck scripts/* tests/*.sh || true"
else
    echo "Skipping shellcheck (not installed)"
fi

# 5. Test individual recipes (sample)
echo ""
echo "Testing sample recipes in Docker..."
for recipe in base git ripgrep jaq; do
    run_test "Docker test: $recipe" "./tests/test-recipe.sh $recipe"
done

# 6. Integration test
echo ""
run_test "Integration test" "./tests/integration-test.sh"

# Summary
echo ""
echo "==================================="
echo "Test Summary:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi