#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install helix"

cd $2/source
git clone git@github.com:helix-editor/helix.git
mkdir -p ~/.config/helix

pushd ~/.config/helix
ln -s $2/source/helix/runtime .
popd

cd helix
cargo install --path helix-term
cd .. && rm -rf helix
