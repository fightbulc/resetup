#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- downloading chrome"
pushd $2/source
wget -cO - https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > chrome.deb

echo "- installing chrome"
sudo dpkg -i chrome.deb
rm chrome.deb
popd
