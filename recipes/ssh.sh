#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup .ssh"

# Get machine name from master.cnf path (e.g., /path/to/machines/dev/master.cnf -> dev)
MACHINE_DIR=$(dirname "$1")
MACHINE_NAME=$(basename "$MACHINE_DIR")

# Determine SSH source directory
SSH_SOURCE_DIR=""

# New structure: machines/[machine]/files/.ssh
if [ -d "$MACHINE_DIR/files/.ssh" ]; then
    SSH_SOURCE_DIR="$MACHINE_DIR/files/.ssh"
# Legacy structure: data/files/.ssh
elif [ -d "$2/data/files/.ssh" ]; then
    SSH_SOURCE_DIR="$2/data/files/.ssh"
# Test structure fallback
elif [ -d "$2/machines/test-machine/files/.ssh" ]; then
    SSH_SOURCE_DIR="$2/machines/test-machine/files/.ssh"
fi

if [ -n "$SSH_SOURCE_DIR" ] && [ -d "$SSH_SOURCE_DIR" ]; then
    echo "  Copying SSH files from: $SSH_SOURCE_DIR"
    cp -r "$SSH_SOURCE_DIR" ~/
else
    echo "  Warning: No SSH files found to copy"
    echo "  Expected location: $MACHINE_DIR/files/.ssh"
    mkdir -p ~/.ssh
fi

chmod 0700 ~/.ssh
if [ -f ~/.ssh/id_rsa ]; then
    chmod 0600 ~/.ssh/id_rsa*
fi
if [ -f ~/.ssh/test_key ]; then
    chmod 0600 ~/.ssh/test_key
fi
