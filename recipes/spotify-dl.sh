#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install spotify-dl"

# Source rust environment if available
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Check if rust/cargo is installed
if ! command -v cargo &> /dev/null; then
    echo "  ⚠️  Cargo is not installed - spotify-dl requires Rust"
    echo "     To install spotify-dl:"
    echo "     1. Run the 'rust' recipe first to install Rust"
    echo "     2. Then run the 'spotify-dl' recipe again"
    echo "  📋 Skipping spotify-dl installation (dependency missing)"
    exit 0
fi

# Install spotify-dl using cargo
echo "  Installing spotify-dl via cargo..."
if cargo install spotify-dl; then
    echo "  ✅ spotify-dl installed successfully"
    echo "     You can now use 'spotify-dl' command to download music from Spotify"
    echo "  ⚠️  Note: Requires Spotify Premium account to function"
    echo "  ⚠️  Use at your own risk - may violate Spotify's Terms of Service"
else
    echo "  ❌ Failed to install spotify-dl"
    echo "     Try running: cargo install spotify-dl"
    exit 1
fi