#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install appimagelauncher (AppImage integration)"

export DEBIAN_FRONTEND=noninteractive

# Add AppImageLauncher PPA
echo "  Adding AppImageLauncher PPA..."
sudo add-apt-repository ppa:appimagelauncher-team/stable -y

# Update package list
echo "  Updating package list..."
sudo apt update

# Install AppImageLauncher
echo "  Installing AppImageLauncher..."
sudo apt install -y appimagelauncher

echo "AppImageLauncher installed successfully"
echo "  ✅ AppImages will now be automatically integrated when opened"
echo "  ✅ Use 'Applications' directory for organized AppImage storage"
echo "  ✅ Right-click AppImages for update/remove options"