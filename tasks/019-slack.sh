#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install slack"

pushd $2/source
wget -cO - https://downloads.slack-edge.com/releases/linux/4.29.149/prod/x64/slack-desktop-4.29.149-amd64.deb > slack.deb
sudo dpkg -i slack.deb 
rm slack.deb
popd
