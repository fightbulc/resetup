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

# Install icon from local assets
echo "  Installing Cursor icon from local assets..."
mkdir -p ~/.local/share/icons

# Copy icon from recipe assets
if [ -f "$2/recipes/assets/cursor.png" ]; then
    cp "$2/recipes/assets/cursor.png" ~/.local/share/icons/cursor.png
    echo "  ✅ Cursor icon installed from local assets"
else
    echo "  ⚠️  Local asset not found, trying to download..."
    # Fallback: download from web
    if wget -cO cursor.png "https://cursor.sh/brand/icon.png" 2>/dev/null; then
        mv cursor.png ~/.local/share/icons/
        echo "  ✅ Cursor icon downloaded and installed"
    else
        echo "  ⚠️  Could not download icon - using default"
    fi
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

popd || exit

echo "Cursor installed successfully"