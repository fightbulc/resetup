#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install Cascadia Code Nerd Font"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Download Cascadia Code Nerd Font
FONT_VERSION="v3.2.1"
wget -cO CascadiaCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/CascadiaCode.zip

# Create fonts directory
mkdir -p ~/.local/share/fonts

# Extract font files
unzip -o CascadiaCode.zip -d ~/.local/share/fonts/CascadiaCode/

# Update font cache
fc-cache -fv ~/.local/share/fonts/

# Clean up
rm CascadiaCode.zip

popd
rm -rf "$TEMP_DIR"

echo "Cascadia Code Nerd Font installed successfully"