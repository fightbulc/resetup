#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install ghostty terminal emulator"

export DEBIAN_FRONTEND=noninteractive

# Use the ghostty-ubuntu installer script
echo "  Installing ghostty using ghostty-ubuntu installer..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

# Set ghostty as default terminal for Ctrl+Alt+T shortcut (Ubuntu 25.04+ method)
echo "  Setting ghostty as default terminal..."
mkdir -p ~/.config
echo "com.mitchellh.ghostty.desktop" > ~/.config/ubuntu-xdg-terminals.list

# Also try the older update-alternatives method for compatibility with older systems
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 60
sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty

echo "  ✅ Ghostty set as default terminal"
echo "ghostty installed successfully"