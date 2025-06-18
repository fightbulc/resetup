#!/usr/bin/env bash
. $1

echo ""
echo "- download beekeeper studio"
echo "  Beekeeper Studio is an open source SQL editor and database manager"
echo "  It provides a modern GUI for managing MySQL, PostgreSQL, SQLite, SQL Server, and more"
echo ""

# Get the latest release URL from GitHub API
# The main AppImage (without architecture suffix) is for x86_64/amd64
# ARM versions have -arm64 suffix
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    # For x86_64, we want the AppImage without architecture suffix
    LATEST_URL=$(curl -s https://api.github.com/repos/beekeeper-studio/beekeeper-studio/releases/latest | grep -E 'browser_download_url.*\.AppImage"' | grep -v 'arm64' | grep -v '.AppImage.blockmap' | cut -d '"' -f 4 | head -n 1)
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    # For ARM, we want the AppImage with -arm64 suffix
    LATEST_URL=$(curl -s https://api.github.com/repos/beekeeper-studio/beekeeper-studio/releases/latest | grep -E 'browser_download_url.*arm64\.AppImage"' | grep -v '.AppImage.blockmap' | cut -d '"' -f 4 | head -n 1)
else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
fi

if [ -z "$LATEST_URL" ]; then
    echo "Error: Could not find latest Beekeeper Studio AppImage URL for architecture: $ARCH"
    exit 1
fi

echo "Downloading from: $LATEST_URL"

# Download to the Downloads directory
cd ~/Downloads
curl -L -o beekeeper-studio.AppImage "$LATEST_URL"

if [ $? -eq 0 ]; then
    chmod +x beekeeper-studio.AppImage
    echo ""
    echo "✓ Beekeeper Studio AppImage downloaded successfully to ~/Downloads/beekeeper-studio.AppImage"
    echo ""
    echo "To run Beekeeper Studio:"
    echo "  ~/Downloads/beekeeper-studio.AppImage"
    echo ""
    echo "For desktop integration, consider using Gear Lever (install with: ./resetup recipes [machine] flatpak)"
else
    echo "Error: Failed to download Beekeeper Studio"
    exit 1
fi