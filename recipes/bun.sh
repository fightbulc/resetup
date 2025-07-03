#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install bun"

# Install bun using the official installer
curl -fsSL https://bun.sh/install | bash

# Add bun to current session
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Add bun to ~/.bashrc if not already present
if ! grep -q "BUN_INSTALL" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# bun" >> ~/.bashrc
    echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
    echo "  ✅ Added bun to ~/.bashrc"
else
    echo "  ✅ Bun already configured in ~/.bashrc"
fi

# Verify bun is accessible
if command -v bun &> /dev/null; then
    echo "  ✅ Bun installed successfully"
    echo "     Bun version: $(bun --version)"
    echo "     You can now use 'bun' command in your terminal"
else
    echo "  ⚠️  Bun was installed but is not available in PATH"
    echo "     Try opening a new terminal or run: source ~/.bashrc"
fi