#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install tunnelto"

cargo install tunnelto
tunnelto set-auth --key $TUNNELTO_KEY