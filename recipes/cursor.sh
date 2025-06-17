#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install cursor (AI-powered code editor)"

pushd $2/source

# Download Cursor AppImage
wget -cO cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x cursor.AppImage

# Move to applications directory
mkdir -p ~/.local/bin
mv cursor.AppImage ~/.local/bin/

# Download and install icon
echo "  Downloading Cursor icon..."
wget -cO cursor.png "https://cursor.sh/brand/icon.png" || {
    # Fallback: try to extract icon from AppImage
    echo "  Fallback: extracting icon from AppImage..."
    ~/.local/bin/cursor.AppImage --appimage-extract usr/share/icons/hicolor/*/apps/cursor.png >/dev/null 2>&1 || true
    if [ -f squashfs-root/usr/share/icons/hicolor/256x256/apps/cursor.png ]; then
        cp squashfs-root/usr/share/icons/hicolor/256x256/apps/cursor.png cursor.png
    fi
    rm -rf squashfs-root
}

mkdir -p ~/.local/share/icons
if [ -f cursor.png ]; then
    mv cursor.png ~/.local/share/icons/
    echo "  ✅ Cursor icon installed"
else
    echo "  ⚠️  Could not download icon - using default"
fi

# Create desktop entry
cat > ~/.local/share/applications/cursor.desktop << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=$HOME/.local/bin/cursor.AppImage %F
Terminal=false
Type=Application
Icon=cursor
Categories=Development;TextEditor;
MimeType=text/plain;inode/directory;
StartupWMClass=Cursor
EOF

popd

echo "Cursor installed successfully"