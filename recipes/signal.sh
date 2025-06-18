#!/usr/bin/env bash

# Signal Desktop installation for Debian-based Linux (Ubuntu, Mint, etc.)

. $1

echo "- setup signal desktop"

# Only works for 64-bit Debian-based distributions
if [[ $(dpkg --print-architecture) != "amd64" ]]; then
    echo "Error: Signal Desktop requires 64-bit architecture"
    exit 1
fi

# 1. Install official public software signing key
echo "Installing Signal signing key..."
wget -qO- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
rm signal-desktop-keyring.gpg

# 2. Add Signal repository
echo "Adding Signal repository..."
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | \
    sudo tee /etc/apt/sources.list.d/signal-xenial.list > /dev/null

# 3. Update package database and install Signal
echo "Installing Signal Desktop..."
sudo apt update
sudo apt install -y signal-desktop

echo "✅ Signal Desktop installed successfully"