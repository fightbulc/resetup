#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- downloading chrome"
TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"
wget -cO - https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > chrome.deb

echo "- installing chrome"
sudo dpkg -i chrome.deb
rm chrome.deb
popd
rm -rf "$TEMP_DIR"
