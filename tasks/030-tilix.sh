#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install tilix"

sudo apt install -y tilix

#
# set tilix theme
#

echo ""
echo "--- install theme"

mkdir -p ~/.config/tilix/schemes

pushd $2/source
wget -qO- https://github.com/dracula/tilix/archive/master.zip > tilix-master.zip
unzip -q tilix-master.zip && cp tilix-master/Dracula.json ~/.config/tilix/schemes/
rm -rf tilix-master && rm tilix-master.zip
popd

#
# set default terminal
#

echo ""
echo "--- set as default terminal"
sudo update-alternatives --config x-terminal-emulator
