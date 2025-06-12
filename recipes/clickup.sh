#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install clickup"

pushd $2/source

# Download ClickUp AppImage
wget -cO clickup.AppImage "https://desktop.clickup.com/linux"
chmod +x clickup.AppImage

# Move to applications directory
mkdir -p ~/.local/bin
mv clickup.AppImage ~/.local/bin/

# Create desktop entry
cat > ~/.local/share/applications/clickup.desktop << EOF
[Desktop Entry]
Name=ClickUp
Comment=Project management and productivity platform
Exec=$HOME/.local/bin/clickup.AppImage %U
Terminal=false
Type=Application
Icon=clickup
Categories=Office;ProjectManagement;
StartupWMClass=ClickUp
MimeType=x-scheme-handler/clickup;
EOF

# Download and install icon
wget -cO clickup.png "https://clickup.com/landing/images/for-se-page/clickup.png"
mkdir -p ~/.local/share/icons
mv clickup.png ~/.local/share/icons/

popd

echo "ClickUp installed successfully"