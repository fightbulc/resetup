#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install sublime merge"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Download Sublime Merge
if [ -f /.dockerenv ]; then
    echo "Running in Docker - skipping Sublime Merge installation (GUI application)"
    exit 0
fi

# Add Sublime's GPG key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

# Add Sublime's APT repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Update package list and install
sudo apt-get update
sudo apt-get install -y sublime-merge

# Apply license if available
LICENSES_DIR="$HOME/.config/sublime-merge/Local"
if [ ! -d "$LICENSES_DIR" ]; then
    mkdir -p "$LICENSES_DIR"
fi

# Get machine name from master.cnf path (e.g., /path/to/machines/dev/master.cnf -> dev)
MACHINE_DIR=$(dirname "$1")
LICENSE_FILE="$MACHINE_DIR/files/sublime-merge-license.txt"

if [ -f "$LICENSE_FILE" ]; then
    echo "Applying Sublime Merge license"
    cp "$LICENSE_FILE" "$LICENSES_DIR/License.sublime_license"
    echo "License applied successfully"
else
    echo "No license file found at $LICENSE_FILE"
    echo "You can manually add your license later through Help > Enter License"
fi

# Clean up
popd
rm -rf "$TEMP_DIR"

echo "sublime merge installed successfully"