#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install lf"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"
wget -cO - https://github.com/gokcehan/lf/releases/download/r8/lf-linux-amd64.tar.gz > lf.tar.gz
tar -xvzf lf.tar.gz
sudo mv lf /usr/local/bin
rm lf.tar.gz
popd
rm -rf "$TEMP_DIR"