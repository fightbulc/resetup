#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install turso"

# Install turso CLI and skip automatic signup
export TURSO_INSTALL_SKIP_SIGNUP=1
curl -sSfL https://get.tur.so/install.sh | bash