#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- download bruno AppImage"

# Create Downloads directory if it doesn't exist
mkdir -p ~/Downloads

# Get the latest Bruno AppImage URL from GitHub releases
echo "  Getting Bruno AppImage download URL..."
BRUNO_URL=$(curl -s https://api.github.com/repos/usebruno/bruno/releases/latest | grep "browser_download_url.*AppImage" | cut -d '"' -f 4)

if [ -z "$BRUNO_URL" ]; then
    echo "  ❌ Failed to get Bruno AppImage download URL"
    exit 1
fi

echo "  Downloading Bruno AppImage from: $BRUNO_URL"
wget -cO ~/Downloads/bruno.AppImage "$BRUNO_URL"
chmod +x ~/Downloads/bruno.AppImage

echo "  ✅ Bruno AppImage downloaded to ~/Downloads/bruno.AppImage"
echo "  💡 Run with --no-sandbox flag: ~/Downloads/bruno.AppImage --no-sandbox"