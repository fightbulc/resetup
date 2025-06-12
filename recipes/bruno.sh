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

# Bruno is distributed as an AppImage
wget -cO bruno.AppImage https://github.com/usebruno/bruno/releases/latest/download/bruno_x86_64_linux.AppImage
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

popd

echo "Bruno installed successfully"