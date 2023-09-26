#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install bun"

curl -fsSL https://bun.sh/install | bash
