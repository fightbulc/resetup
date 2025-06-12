#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install jaq (rust-based jq)"

pushd $2/source

# Get the latest jaq version
JAQ_VERSION=$(curl -s "https://api.github.com/repos/01mf02/jaq/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# Download jaq binary
wget -cO jaq "https://github.com/01mf02/jaq/releases/download/v${JAQ_VERSION}/jaq-v${JAQ_VERSION}-x86_64-unknown-linux-gnu"

# Make executable and install
chmod +x jaq
sudo install jaq /usr/local/bin/

# Clean up
rm jaq

popd

echo "jaq installed successfully"