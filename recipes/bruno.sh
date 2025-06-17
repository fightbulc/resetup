#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install bruno (API client)"

export DEBIAN_FRONTEND=noninteractive

# Add the Bruno repository key
echo "  Adding Bruno repository key..."
sudo mkdir -p /etc/apt/keyrings 
sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/bruno.gpg --keyserver keyserver.ubuntu.com --recv-keys 9FA6017ECABE0266

# Add the Bruno repository
echo "  Adding Bruno repository..."
echo "deb [signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable" | sudo tee /etc/apt/sources.list.d/bruno.list

# Update package list
echo "  Updating package list..."
sudo apt update

# Install Bruno
echo "  Installing Bruno..."
sudo apt install -y bruno

echo "Bruno installed successfully"