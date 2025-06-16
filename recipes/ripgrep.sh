#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install ripgrep"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

pushd $2/source

# Get the latest ripgrep version
RG_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[^"]*')

# Download ripgrep
wget -cO ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}-1_amd64.deb"

# Install
sudo dpkg -i ripgrep.deb

# Fix any dependency issues
sudo apt-get install -f -y

# Clean up
rm ripgrep.deb

popd

echo "ripgrep installed successfully"