#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install obsidian"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"
wget -cO - https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.10/obsidian_1.8.10_amd64.deb > obsidian.deb
sudo dpkg -i obsidian.deb
rm obsidian.deb
popd
rm -rf "$TEMP_DIR"
