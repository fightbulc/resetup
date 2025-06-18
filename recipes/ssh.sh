#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup .ssh"

# Handle both old and new data structure paths
if [ -d "$2/data/files/.ssh" ]; then
    # Old structure
    cp -r $2/data/files/.ssh ~/
elif [ -d "$2/machines/test-machine/files/.ssh" ]; then
    # New test structure
    cp -r $2/machines/test-machine/files/.ssh ~/
else
    echo "Warning: No SSH files found to copy"
    mkdir -p ~/.ssh
fi

chmod 0700 ~/.ssh
if [ -f ~/.ssh/id_rsa ]; then
    chmod 0600 ~/.ssh/id_rsa*
fi
if [ -f ~/.ssh/test_key ]; then
    chmod 0600 ~/.ssh/test_key
fi
