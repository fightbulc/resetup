#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install bruno (API client)"

pushd $2/source

# Get the latest Bruno version and download URL
echo "  Getting latest Bruno version from GitHub releases..."
BRUNO_VERSION=$(curl -s "https://github.com/usebruno/bruno/releases/latest/download/latest-linux.yml" | grep "^version:" | cut -d' ' -f2)

if [ -z "$BRUNO_VERSION" ]; then
    echo "  ❌ Failed to get Bruno version from GitHub releases"
    exit 1
fi

BRUNO_URL="https://github.com/usebruno/bruno/releases/latest/download/bruno_${BRUNO_VERSION}_x86_64_linux.AppImage"
echo "  Downloading Bruno v$BRUNO_VERSION from: $BRUNO_URL"
wget -cO bruno.AppImage "$BRUNO_URL"
chmod +x bruno.AppImage

# Move to applications directory
mkdir -p ~/.local/bin
mv bruno.AppImage ~/.local/bin/

# Create desktop entry
cat > ~/.local/share/applications/bruno.desktop << EOF
[Desktop Entry]
Name=Bruno
Comment=Opensource IDE for exploring and testing APIs
Exec=$HOME/.local/bin/bruno.AppImage %U
Terminal=false
Type=Application
Icon=bruno
Categories=Development;
StartupWMClass=Bruno
EOF

# Download and install icon
wget -cO bruno.png https://raw.githubusercontent.com/usebruno/bruno/main/packages/bruno-electron/resources/icons/png/256x256.png
mkdir -p ~/.local/share/icons
mv bruno.png ~/.local/share/icons/

popd || exit

echo "Bruno installed successfully"