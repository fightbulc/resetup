#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install obsidian"

pushd $2/source
wget -cO - https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.10/obsidian_1.8.10_amd64.deb > obsidian.deb
sudo dpkg -i obsidian.deb
rm obsidian.deb
popd
