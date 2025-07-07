#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install slack"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"
wget -cO - https://downloads.slack-edge.com/desktop-releases/linux/x64/4.43.51/slack-desktop-4.43.51-amd64.deb > slack.deb
sudo dpkg -i slack.deb 
rm slack.deb
popd
rm -rf "$TEMP_DIR"
