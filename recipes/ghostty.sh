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

cd ..
rm -rf ghostty

popd

echo "ghostty installed successfully"