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
if ! command -v nmcli >/dev/null 2>&1; then
    echo "  Installing NetworkManager..."
    sudo apt-get update
    sudo apt-get install -y network-manager
fi

# Check if WiFi device is available
if ! nmcli device | grep -q wifi; then
    echo "  ⚠️  No WiFi device found - skipping WiFi setup"
    echo "  This is normal for virtual machines or wired-only systems"
    exit 0
fi

# Scan for available networks
echo "  Scanning for WiFi networks..."
sudo nmcli device wifi rescan 2>/dev/null || true

# Create NetworkManager connection
echo "  Attempting to connect to $WIFI_ID..."
if sudo nmcli device wifi connect "$WIFI_ID" password "$WIFI_PASSWORD" 2>/dev/null; then
    echo "  ✅ WiFi connection successful"
elif nmcli connection show --active | grep -q "$WIFI_ID" 2>/dev/null; then
    echo "  ✅ WiFi already connected to $WIFI_ID"
else
    echo "  ⚠️  WiFi connection failed"
    echo "     Possible reasons:"
    echo "     - Network '$WIFI_ID' is not in range"
    echo "     - Incorrect password"
    echo "     - Network requires additional authentication"
    echo "  📋 Continuing with installation (WiFi setup is non-critical)"
fi