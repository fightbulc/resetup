#!/usr/bin/env bash

# Test script for the clean command
# This script tests the functionality of removing all installed receipts

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test directory setup
TEST_DIR=$(mktemp -d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLEAN_SCRIPT="$PROJECT_ROOT/clean"

# Copy necessary files to test directory
cp "$CLEAN_SCRIPT" "$TEST_DIR/clean"
chmod +x "$TEST_DIR/clean"

# Change to test directory
cd "$TEST_DIR"

echo -e "${YELLOW}Running clean command tests...${NC}"

# Test 1: Clean when no receipts file exists
echo -n "Test 1: Clean with no existing receipts file... "
OUTPUT=$(./clean 2>&1)
if [[ "$OUTPUT" == *"No installed receipts found"* ]] && [[ "$OUTPUT" == *"System is already clean"* ]]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected: Message about no installed receipts"
    echo "Got: $OUTPUT"
    exit 1
fi

# Test 2: Clean with empty receipts file
echo -n "Test 2: Clean with empty receipts file... "
touch .installed_recipes
OUTPUT=$(./clean 2>&1)
if [[ "$OUTPUT" == *"Removed 0 installed receipt(s)"* ]] && [[ ! -f .installed_recipes ]]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected: Removed 0 receipts and file deleted"
    echo "Got: $OUTPUT"
    exit 1
fi

# Test 3: Clean with single receipt
echo -n "Test 3: Clean with single receipt... "
echo "golang" > .installed_recipes
OUTPUT=$(./clean 2>&1)
if [[ "$OUTPUT" == *"Removed 1 installed receipt(s)"* ]] && [[ ! -f .installed_recipes ]]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected: Removed 1 receipt and file deleted"
    echo "Got: $OUTPUT"
    exit 1
fi

# Test 4: Clean with multiple receipts
echo -n "Test 4: Clean with multiple receipts... "
cat > .installed_recipes << EOF
base
golang
docker
nodejs
EOF
OUTPUT=$(./clean 2>&1)
if [[ "$OUTPUT" == *"Removed 4 installed receipt(s)"* ]] && [[ ! -f .installed_recipes ]]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected: Removed 4 receipts and file deleted"
    echo "Got: $OUTPUT"
    exit 1
fi

# Test 5: Clean is idempotent (running twice)
echo -n "Test 5: Clean is idempotent... "
echo "test-recipe" > .installed_recipes
./clean >/dev/null 2>&1
OUTPUT=$(./clean 2>&1)
if [[ "$OUTPUT" == *"No installed receipts found"* ]] && [[ "$OUTPUT" == *"System is already clean"* ]]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected: System already clean on second run"
    echo "Got: $OUTPUT"
    exit 1
fi

# Test 6: Clean preserves working directory
echo -n "Test 6: Clean preserves working directory... "
ORIGINAL_PWD=$(pwd)
mkdir -p subdir
cd subdir
echo "recipe1" > ../.installed_recipes
../clean >/dev/null 2>&1
CURRENT_PWD=$(pwd)
cd ..
if [[ "$ORIGINAL_PWD/subdir" == "$CURRENT_PWD" ]]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected working directory to be preserved"
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo -e "${GREEN}All clean command tests passed!${NC}"