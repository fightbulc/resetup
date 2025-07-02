#!/usr/bin/env bash

echo "Testing tunnelto recipe..."

# Check if tunnelto binary exists
if ! command -v tunnelto &> /dev/null; then
    echo "ERROR: tunnelto not found in PATH"
    exit 1
fi

echo "✓ tunnelto binary found"

# Check tunnelto version
if tunnelto --version &> /dev/null; then
    echo "✓ tunnelto version check passed"
else
    echo "ERROR: tunnelto version check failed"
    exit 1
fi

echo "tunnelto recipe test passed!"