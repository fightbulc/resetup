#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install discord"

# Check if running in Docker or if snapd daemon is not running
if [ -f /.dockerenv ] || ! systemctl is-active --quiet snapd 2>/dev/null; then
    echo "  ! snap not available, falling back to .deb installation"
    
    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR"
    wget -cO - "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
    sudo dpkg -i discord.deb 
    rm discord.deb
    popd
    rm -rf "$TEMP_DIR"
else
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "  ! snap is not installed. Installing snapd..."
        sudo apt update
        sudo apt install -y snapd
    fi
    
    # Install Discord via snap
    echo "  - installing discord via snap"
    sudo snap install discord || {
        echo "  ! failed to install discord via snap, falling back to .deb"
        TEMP_DIR=$(mktemp -d)
        pushd "$TEMP_DIR"
        wget -cO - "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
        sudo dpkg -i discord.deb 
        rm discord.deb
        popd
        rm -rf "$TEMP_DIR"
    }
fi