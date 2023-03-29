#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup .ssh"

cp -r $2/data/files/.ssh ~/
chmod 0700 ~/.ssh && chmod 0600 ~/.ssh/id_rsa*
ssh -o "StrictHostKeyChecking no" -T git@github.com
