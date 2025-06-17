#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install claude-code CLI"

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "  ⚠️  npm is not installed - Claude Code CLI requires Node.js/npm"
    echo "     To install Claude Code CLI:"
    echo "     1. Run the 'nvm' recipe first to install Node.js"
    echo "     2. Then run the 'claude-code' recipe again"
    echo "  📋 Skipping Claude Code CLI installation (dependency missing)"
    exit 0
fi

# Install claude-code globally
echo "  Installing Claude Code CLI via npm..."
if npm install -g @anthropic-ai/claude-code; then
    echo "  ✅ Claude Code CLI installed successfully"
    echo "     You can now use 'claude' command in your terminal"
else
    echo "  ⚠️  Claude Code CLI installation failed"
    echo "     Try running: npm install -g @anthropic-ai/claude-code"
    echo "  📋 Continuing with installation (Claude Code CLI is optional)"
fi