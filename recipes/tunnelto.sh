#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install tunnelto"

# Download and install tunnelto
curl -sL https://tunnelto.dev/install.sh | sh

# Create directory for tunnelto binary if it doesn't exist
mkdir -p ~/.local/bin

# Add ~/.local/bin to PATH in .bashrc if not already there
if ! grep -q "/.local/bin" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Tunnelto" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HOME/.local/bin" >> ~/.bashrc
fi

# Configure API key if TUNNELTO_KEY is set
if [ ! -z "$TUNNELTO_KEY" ]; then
    echo "- configure tunnelto API key"
    export PATH=$PATH:$HOME/.local/bin
    echo "$TUNNELTO_KEY" | tunnelto set-auth
fi

echo "Tunnelto installed successfully"
echo "Please run 'source ~/.bashrc' or restart your terminal to update PATH"
echo ""
echo "Usage:"
echo "  tunnelto --port 8000                    # Basic tunnel with random subdomain"
echo "  tunnelto --port 8000 --subdomain myapp  # Custom subdomain (requires API key)"
echo ""
if [ -z "$TUNNELTO_KEY" ]; then
    echo "Get API key from: https://dashboard.tunnelto.dev"
    echo "Store API key: tunnelto set-auth"
else
    echo "API key configured automatically from master.cnf"
fi