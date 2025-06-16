#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install discord"

pushd $2/source
wget -cO - "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
sudo dpkg -i discord.deb 
rm discord.deb
popd