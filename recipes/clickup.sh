#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install clickup (project management platform)"

pushd $2/source

# Download ClickUp AppImage
echo "  Downloading ClickUp AppImage..."
wget -cO clickup.AppImage "https://desktop.clickup.com/linux"
chmod +x clickup.AppImage

# Move to Downloads folder for AppImageLauncher to handle
mkdir -p ~/Downloads
mv clickup.AppImage ~/Downloads/

echo "  ✅ ClickUp AppImage ready - AppImageLauncher will handle integration"
echo "  💡 When you first run ClickUp, AppImageLauncher will:"
echo "     - Extract and install the icon automatically"
echo "     - Create proper desktop entry" 
echo "     - Move AppImage to ~/Applications directory"
echo "     - Offer integration options"

popd || exit

echo "ClickUp installed successfully"