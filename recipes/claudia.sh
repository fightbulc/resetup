#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install claudia (production build)"

# Check dependencies
echo "  Checking dependencies..."

# Source rust environment if available
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Check if rust is installed
if ! command -v rustc &> /dev/null; then
    echo "  ⚠️  Rust is not installed - Claudia requires Rust"
    echo "     To install Claudia:"
    echo "     1. Run the 'rust' recipe first to install Rust"
    echo "     2. Then run the 'claudia' recipe again"
    echo "  📋 Skipping Claudia installation (dependency missing)"
    exit 0
fi

# Source bun environment if available
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

# Check if bun is installed
if ! command -v bun &> /dev/null; then
    echo "  ⚠️  Bun is not installed - Claudia requires Bun"
    echo "     To install Claudia:"
    echo "     1. Run the 'bun' recipe first to install Bun"
    echo "     2. Then run the 'claudia' recipe again"
    echo "  📋 Skipping Claudia installation (dependency missing)"
    exit 0
fi

# Check if claude is installed
if ! command -v claude &> /dev/null; then
    echo "  ⚠️  Claude Code CLI is not installed - Claudia requires Claude Code CLI"
    echo "     To install Claudia:"
    echo "     1. Run the 'nvm' recipe first to install Node.js"
    echo "     2. Run the 'claude-code' recipe to install Claude Code CLI"
    echo "     3. Then run the 'claudia' recipe again"
    echo "  📋 Skipping Claudia installation (dependency missing)"
    exit 0
fi

# Install system dependencies for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  Installing Linux system dependencies..."
    sudo apt update
    sudo apt install -y \
        libwebkit2gtk-4.1-dev \
        build-essential \
        curl \
        wget \
        file \
        libssl-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev
fi

# Create a directory for building
BUILD_DIR="$HOME/.local/tmp/claudia-build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clone the repository
echo "  Cloning Claudia repository..."
if [ -d "claudia" ]; then
    echo "  Removing existing claudia directory..."
    rm -rf claudia
fi

git clone https://github.com/getAsterisk/claudia.git
cd claudia

# Install frontend dependencies
echo "  Installing frontend dependencies..."
bun install

# Build for production
echo "  Building Claudia for production (this may take a few minutes)..."
bun run tauri build

# Find the built executable
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    BUILT_APP=$(find src-tauri/target/release/bundle -name "*.AppImage" -type f 2>/dev/null | head -n1)
    if [ -z "$BUILT_APP" ]; then
        BUILT_APP=$(find src-tauri/target/release/bundle -name "claudia" -type f -executable 2>/dev/null | head -n1)
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    BUILT_APP=$(find src-tauri/target/release/bundle -name "*.app" -type d 2>/dev/null | head -n1)
fi

if [ -z "$BUILT_APP" ]; then
    echo "  ❌ Failed to find built Claudia application"
    echo "     Build artifacts should be in: src-tauri/target/release/bundle/"
    exit 1
fi

# Install the application
echo "  Installing Claudia..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ "$BUILT_APP" == *.AppImage ]]; then
        # Copy AppImage to Downloads
        mkdir -p ~/Downloads
        cp "$BUILT_APP" ~/Downloads/claudia.AppImage
        chmod +x ~/Downloads/claudia.AppImage
        echo "  ✅ Claudia AppImage installed to ~/Downloads/claudia.AppImage"
        echo "  💡 You can run it with: ~/Downloads/claudia.AppImage"
        echo "  💡 Use Gear Lever (flatpak recipe) for desktop integration"
    else
        # Copy binary to ~/.local/bin
        mkdir -p ~/.local/bin
        cp "$BUILT_APP" ~/.local/bin/claudia
        chmod +x ~/.local/bin/claudia
        echo "  ✅ Claudia installed to ~/.local/bin/claudia"
        echo "  💡 Make sure ~/.local/bin is in your PATH"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Copy to Applications on macOS
    cp -R "$BUILT_APP" /Applications/
    echo "  ✅ Claudia installed to /Applications/"
fi

# Clean up build directory
cd "$HOME"
rm -rf "$BUILD_DIR"

echo "  ✅ Claudia installation complete"
echo "  📝 Claudia is a GUI wrapper for Claude Code CLI"
echo "  📝 Make sure Claude Code CLI is properly configured before using Claudia"