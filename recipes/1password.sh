#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- 1password"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Download 1Password deb package directly
wget -O 1password.deb https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb

# Install 1Password
sudo dpkg -i 1password.deb

# Fix any dependency issues
sudo apt-get install -f -y

# Clean up
rm 1password.deb 
