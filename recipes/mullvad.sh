#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install mullvad vpn"

# Check if running in Docker environment
if [ -f /.dockerenv ]; then
    echo "  Docker environment detected - skipping Mullvad VPN installation"
    echo "  (VPN clients cannot run properly in containers)"
    exit 0
fi

# Install dependencies
sudo apt update
sudo apt -y install curl gpg

# Add Mullvad repository signing key
echo "  Adding Mullvad repository signing key..."
sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

# Add Mullvad repository
echo "  Adding Mullvad repository..."
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list

# Update package list and install Mullvad VPN
echo "  Installing Mullvad VPN..."
sudo apt update
sudo apt -y install mullvad-vpn

# Enable and start Mullvad daemon
echo "  Enabling Mullvad daemon..."
sudo systemctl enable mullvad-daemon
sudo systemctl start mullvad-daemon

echo "  Mullvad VPN installation completed!"

# Auto-login if account token is provided
if [ -n "$MULLVAD_ACCOUNT_TOKEN" ]; then
    echo "  Logging into Mullvad account..."
    mullvad account login "$MULLVAD_ACCOUNT_TOKEN"
    if [ $? -eq 0 ]; then
        echo "  Successfully logged into Mullvad account!"
    else
        echo "  Failed to login to Mullvad account. Please check your token."
    fi
else
    echo "  No MULLVAD_ACCOUNT_TOKEN found in master.cnf"
    echo "  You can manually login with: mullvad account login [ACCOUNT]"
fi

echo "  You can now run 'mullvad-gui' to set up your VPN connection"
echo "  or use 'mullvad' command line tool for configuration"