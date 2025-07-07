#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install jaq (rust-based jq)"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Get the latest jaq version
JAQ_VERSION=$(curl -s "https://api.github.com/repos/01mf02/jaq/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# Download jaq binary
wget "https://github.com/01mf02/jaq/releases/download/v${JAQ_VERSION}/jaq-x86_64-unknown-linux-gnu" -O jaq

# Make executable and install
chmod +x jaq
sudo install jaq /usr/local/bin/

# Clean up
rm jaq

popd
rm -rf "$TEMP_DIR"

echo "jaq installed successfully"