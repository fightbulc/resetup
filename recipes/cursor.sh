#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- download cursor AppImage"

# Create Downloads directory if it doesn't exist
mkdir -p ~/Downloads

# Get the actual download URL from Cursor API
echo "  Getting download URL from Cursor API..."
CURSOR_URL=$(curl -s "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4)

if [ -z "$CURSOR_URL" ]; then
    echo "  ❌ Failed to get download URL from Cursor API"
    exit 1
fi

echo "  Downloading Cursor from: $CURSOR_URL"
wget -cO ~/Downloads/cursor.AppImage "$CURSOR_URL"
chmod +x ~/Downloads/cursor.AppImage

echo "  ✅ Cursor AppImage downloaded to ~/Downloads/cursor.AppImage"
echo "  💡 Note: Cursor does not include --no-sandbox flag by default"
echo "  💡 When using with Gear Lever, add --no-sandbox flag for proper sandbox handling"