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
export TZ=UTC

# Ghostty requires building from source
# First ensure we have the build dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    python3 \
    cargo

pushd $2/source

# Clone ghostty repository
git clone https://github.com/ghostty-org/ghostty.git
cd ghostty

# Build ghostty
cargo build --release

# Install binary
sudo install -m 755 target/release/ghostty /usr/local/bin/

# Install desktop entry
cat > ~/.local/share/applications/ghostty.desktop << EOF
[Desktop Entry]
Name=Ghostty
Comment=GPU-accelerated terminal emulator
Exec=/usr/local/bin/ghostty
Terminal=false
Type=Application
Icon=utilities-terminal
Categories=System;TerminalEmulator;
StartupWMClass=ghostty
EOF

# Set ghostty as default terminal for Ctrl+Alt+T shortcut (Ubuntu 25.04+ method)
echo "  Setting ghostty as default terminal..."
mkdir -p ~/.config
echo "ghostty.desktop" > ~/.config/ubuntu-xdg-terminals.list

# Also try the older update-alternatives method for compatibility with older systems
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/ghostty 60
sudo update-alternatives --set x-terminal-emulator /usr/local/bin/ghostty

echo "  ✅ Ghostty set as default terminal"

cd ..
rm -rf ghostty

popd

echo "ghostty installed successfully"