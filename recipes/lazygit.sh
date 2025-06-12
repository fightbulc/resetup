#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install lazygit"

pushd $2/source

# Get the latest version
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# Download lazygit binary
wget -cO lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

# Extract
tar xzf lazygit.tar.gz lazygit

# Install
sudo install lazygit /usr/local/bin

# Clean up
rm lazygit.tar.gz lazygit

popd

echo "lazygit installed successfully"