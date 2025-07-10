#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install Cascadia Code Font"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Download Cascadia Code from official Microsoft repository
FONT_VERSION="v2407.24"
wget -cO CascadiaCode.zip https://github.com/microsoft/cascadia-code/releases/download/${FONT_VERSION}/CascadiaCode-2407.24.zip

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

echo "Cascadia Code Font installed successfully"