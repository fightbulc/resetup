#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- solaar"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Add the Solaar PPA repository
sudo add-apt-repository ppa:solaar-unifying/stable -y

# Update package lists
sudo apt update

# Install Solaar
sudo apt install -y solaar

echo "✓ Solaar installed successfully"
echo "  You can now manage Logitech Unifying devices"
echo "  Run 'solaar' to start the GUI or 'solaar-cli' for command line"