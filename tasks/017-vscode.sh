#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install vscode"

pushd ~/Downloads
wget -cO - "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > vscode.deb
sudo dpkg -i vscode.deb 
rm vscode.deb
popd
