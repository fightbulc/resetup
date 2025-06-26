#!/usr/bin/env bash
# Load master configuration
. $1

echo "- install telegram"

# Check if running in Docker or if snapd daemon is not running
if [ -f /.dockerenv ] || ! systemctl is-active --quiet snapd 2>/dev/null; then
    echo "  ! snap not available, using direct download method"
    
    # Download and extract Telegram
    echo "  - downloading telegram desktop"
    cd /tmp
    wget -q -O telegram.tar.xz https://telegram.org/dl/desktop/linux || {
        echo "  ! failed to download telegram"
        exit 1
    }
    
    echo "  - extracting telegram"
    sudo mkdir -p /opt
    sudo tar -xf telegram.tar.xz -C /opt/ || {
        echo "  ! failed to extract telegram"
        exit 1
    }
    
    # Create symlink
    sudo ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram-desktop
    
    # Cleanup
    rm -f telegram.tar.xz
    
    echo "  ✓ telegram installed successfully (direct download)"
else
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "  ! snap is not installed. Installing snapd..."
        sudo apt update
        sudo apt install -y snapd
    fi
    
    # Install Telegram Desktop via snap
    echo "  - installing telegram desktop via snap"
    sudo snap install telegram-desktop || {
        echo "  ! failed to install telegram via snap"
        exit 1
    }
    
    echo "  ✓ telegram installed successfully via snap"
fi