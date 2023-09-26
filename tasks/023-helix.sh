#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install helix"

sudo add-apt-repository ppa:maveonair/helix-editor
sudo sed -E "s/mantic/lunar/g" -- /etc/apt/sources.list.d/maveonair-ubuntu-helix-editor-mantic.sources > /etc/apt/sources.list.d/maveonair-ubuntu-helix-editor-mantic.sources
sudo apt update && apt -y upgrade && apt install -y helix