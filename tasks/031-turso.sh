#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install turso"

curl -sSfL https://get.tur.so/install.sh | bash