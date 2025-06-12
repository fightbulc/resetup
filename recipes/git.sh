#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup git"

git config --global user.name "$GIT_USERNAME"
git config --global user.email $GIT_EMAIL
git config --global init.defaultBranch main
ssh -o "StrictHostKeyChecking no" -T git@github.com