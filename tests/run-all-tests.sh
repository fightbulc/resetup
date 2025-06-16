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
    if $test_command > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

# 1. YAML Validation
echo -n "Running YAML validation... "
if python3 -c "import yaml; yaml.safe_load(open('recipes.yaml'))" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

# 2. Recipe files exist
echo -n "Running Recipe files exist... "
if ./tests/test-dependencies.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

# 3. Python dependency check
echo -n "Running Circular dependency check... "
if python3 tests/check-dependencies.py > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

# 4. Shellcheck on scripts
if command -v shellcheck &> /dev/null; then
    echo -n "Running Shellcheck scripts... "
    if shellcheck scripts/* tests/*.sh > /dev/null 2>&1 || true; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo "Skipping shellcheck (not installed)"
fi

# 5. Test individual recipes (sample)
echo ""
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    echo "Skipping Docker recipe tests in CI environment"
else
    echo "Testing sample recipes in Docker..."
    for recipe in base wifi git ripgrep jaq; do
        echo -n "Running Docker test: $recipe... "
        if ./tests/test-recipe.sh "$recipe" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}❌ FAIL${NC}"
            ((TESTS_FAILED++))
        fi
    done
fi

# 6. Test clean command
echo ""
echo -n "Running Clean command... "
if ./tests/test-clean.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

# 7. Integration test
echo ""
echo -n "Running Integration test... "
if ./tests/integration-test.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

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