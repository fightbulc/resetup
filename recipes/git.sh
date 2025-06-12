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

# Test SSH connectivity to GitHub (non-fatal)
if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
    echo "Testing SSH connection to GitHub..."
    ssh -o "StrictHostKeyChecking no" -T git@github.com || true
else
    echo "No SSH keys found, skipping GitHub connectivity test"
fi