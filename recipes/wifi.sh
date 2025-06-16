#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup wifi"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Check if WiFi credentials are provided
if [ -z "$WIFI_ID" ] || [ -z "$WIFI_PASSWORD" ]; then
    echo "  WiFi credentials not found in config, skipping WiFi setup"
    exit 0
fi

echo "  Connecting to WiFi network: $WIFI_ID"

# Install network manager if not present
sudo apt-get update
sudo apt-get install -y network-manager

# Create NetworkManager connection
sudo nmcli device wifi connect "$WIFI_ID" password "$WIFI_PASSWORD"

# Verify connection
if nmcli connection show --active | grep -q "$WIFI_ID"; then
    echo "  WiFi connection successful"
else
    echo "  WiFi connection failed"
    exit 1
fi