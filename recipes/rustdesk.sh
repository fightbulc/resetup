#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install rustdesk"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Download RustDesk deb package
wget -cO rustdesk.deb https://github.com/rustdesk/rustdesk/releases/download/1.4.0/rustdesk-1.4.0-x86_64.deb

# Install RustDesk
sudo dpkg -i rustdesk.deb

# Fix any dependency issues
sudo apt-get install -f -y

# Clean up
rm rustdesk.deb

popd
rm -rf "$TEMP_DIR"

echo "RustDesk installed successfully"