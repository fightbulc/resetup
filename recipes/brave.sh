#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install brave browser"

# Check if running in Docker or if snap is not available
if [ -f /.dockerenv ] || ! systemctl is-active --quiet snapd 2>/dev/null; then
    echo "  ! snap not available, falling back to .deb installation"
    
    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR"
    
    # Add Brave repository
    curl -fsSLo /tmp/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo mv /tmp/brave-browser-archive-keyring.gpg /usr/share/keyrings/brave-browser-archive-keyring.gpg
    
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    
    # Update package list and install Brave
    sudo apt update
    sudo apt install -y brave-browser
    
    popd
    rm -rf "$TEMP_DIR"
else
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "  ! snap command not found, installing snapd"
        sudo apt update
        sudo apt install -y snapd
    fi
    
    # Install Brave via snap
    echo "  - installing brave browser via snap"
    sudo snap install brave || {
        echo "  ! failed to install brave via snap, falling back to .deb"
        
        TEMP_DIR=$(mktemp -d)
        pushd "$TEMP_DIR"
        
        # Add Brave repository
        curl -fsSLo /tmp/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        sudo mv /tmp/brave-browser-archive-keyring.gpg /usr/share/keyrings/brave-browser-archive-keyring.gpg
        
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        
        # Update package list and install Brave
        sudo apt update
        sudo apt install -y brave-browser
        
        popd
        rm -rf "$TEMP_DIR"
    }
fi

echo "  ✅ Brave browser installed successfully"