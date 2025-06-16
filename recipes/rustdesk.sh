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

pushd $2/source

# Download RustDesk deb package
wget -cO rustdesk.deb https://github.com/rustdesk/rustdesk/releases/download/1.4.0/rustdesk-1.4.0-x86_64.deb

# Install RustDesk
sudo dpkg -i rustdesk.deb

# Fix any dependency issues
sudo apt-get install -f -y

# Clean up
rm rustdesk.deb

popd

echo "RustDesk installed successfully"