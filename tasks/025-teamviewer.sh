#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install teamviewer"

pushd /tmp
wget -cO - https://download.teamviewer.com/download/linux/teamviewer_amd64.deb > teamviewer.deb
sudo dpkg -i teamviewer.deb 
rm teamviewer.deb
popd