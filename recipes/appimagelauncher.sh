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

# Download and install AppImageLauncher directly
echo "  Downloading AppImageLauncher..."
cd /tmp || exit 1
wget -O appimagelauncher.deb "https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher_2.2.0-travis995.0f91801.bionic_amd64.deb"

echo "  Installing AppImageLauncher..."
sudo dpkg -i appimagelauncher.deb

# Fix any dependency issues
echo "  Fixing dependencies..."
sudo apt-get install -f -y

echo "AppImageLauncher installed successfully"
echo "  ✅ AppImages will now be automatically integrated when opened"
echo "  ✅ Use 'Applications' directory for organized AppImage storage"
echo "  ✅ Right-click AppImages for update/remove options"