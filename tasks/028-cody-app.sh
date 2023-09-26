#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install cody app"

pushd $2/source
wget -cO - https://sourcegraph.com/.api/app/latest?arch=x86_64&target=linux > cody-app.tar.gz

