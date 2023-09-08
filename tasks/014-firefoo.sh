#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install firefoo"

pushd $2/source
wget -cO - https://github.com/mltek/firefoo-releases/releases/download/v1.5.11/firefoo_1.5.11_amd64.deb > firefoo.deb
sudo dpkg -i firefoo.deb 
rm firefoo.deb
popd
