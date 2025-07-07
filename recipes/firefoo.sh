#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install firefoo"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"
wget -cO - https://github.com/mltek/firefoo-releases/releases/download/v1.5.11/firefoo_1.5.11_amd64.deb > firefoo.deb
sudo dpkg -i firefoo.deb 
rm firefoo.deb
popd
rm -rf "$TEMP_DIR"
