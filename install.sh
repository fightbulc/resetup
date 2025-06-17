#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default installation directory
INSTALL_DIR="$HOME/resetup"

# Parse command line arguments
SKIP_CLONE=false
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --skip-clone)
            SKIP_CLONE=true
            shift
            ;;
        -h|--help)
            echo "Resetup Installer"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes       Skip confirmation prompts"
            echo "  --dir DIR       Install to custom directory (default: ~/resetup)"
            echo "  --skip-clone    Skip git clone (for updating existing installation)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Examples:"
            echo "  curl -fsSL https://raw.githubusercontent.com/fightbulc/resetup/main/install.sh | bash"
            echo "  curl -fsSL https://raw.githubusercontent.com/fightbulc/resetup/main/install.sh | bash -s -- -y"
            echo "  curl -fsSL https://raw.githubusercontent.com/fightbulc/resetup/main/install.sh | bash -s -- --dir /opt/resetup"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 Resetup Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ git is required but not installed${NC}"
    echo "Please install git first:"
    echo "  sudo apt update && sudo apt install git"
    exit 1
fi

# Check for curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl is required but not installed${NC}"
    echo "Please install curl first:"
    echo "  sudo apt update && sudo apt install curl"
    exit 1
fi

# Check for openssl
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}❌ openssl is required but not installed${NC}"
    echo "Please install openssl first:"
    echo "  sudo apt update && sudo apt install openssl"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Show installation details
echo -e "${YELLOW}Installation details:${NC}"
echo "  📁 Directory: $INSTALL_DIR"
echo "  🔧 Auto-confirm: $AUTO_YES"
echo "  📋 Skip clone: $SKIP_CLONE"
echo ""

# Confirm installation
if [ "$AUTO_YES" != "true" ]; then
    read -p "Continue with installation? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Create parent directory if needed
PARENT_DIR=$(dirname "$INSTALL_DIR")
if [ ! -d "$PARENT_DIR" ]; then
    echo -e "${YELLOW}Creating parent directory: $PARENT_DIR${NC}"
    mkdir -p "$PARENT_DIR"
fi

# Clone or update repository
if [ "$SKIP_CLONE" = "true" ]; then
    echo -e "${YELLOW}Skipping git clone (--skip-clone specified)${NC}"
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}❌ Directory $INSTALL_DIR does not exist${NC}"
        exit 1
    fi
else
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Directory exists, updating...${NC}"
        cd "$INSTALL_DIR"
        git pull
    else
        echo -e "${YELLOW}Cloning resetup repository...${NC}"
        git clone https://github.com/fightbulc/resetup.git "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
fi

# Make resetup executable
chmod +x "$INSTALL_DIR/resetup"

# Add to PATH if not already there
SHELL_RC="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

# Check if already in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Adding resetup to PATH in $SHELL_RC...${NC}"
    echo "" >> "$SHELL_RC"
    echo "# Resetup" >> "$SHELL_RC"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    export PATH="$INSTALL_DIR:$PATH"
    echo -e "${GREEN}✅ Added to PATH${NC}"
else
    echo -e "${GREEN}✅ Already in PATH${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}🎉 Resetup installed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Restart your terminal or run: source $SHELL_RC"
echo "  2. Initialize resetup: resetup init"
echo "  3. Configure your settings: vim ~/resetup/data/config/master.cnf"
echo "  4. Encrypt your config: resetup pack"
echo "  5. Install recipes: resetup unpack -y"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  resetup help    # Show available commands"
echo "  resetup docker  # Test in Docker environment"
echo ""
echo -e "${BLUE}Documentation: https://github.com/fightbulc/resetup${NC}"
echo ""