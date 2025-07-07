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
    
    # Add Claude Code alias to ~/.bashrc
    echo "- add claude code alias to ~/.bashrc"
    if ! grep -q "alias cc=" ~/.bashrc; then
        echo 'alias cc="claude --dangerously-skip-permissions"' >> ~/.bashrc
        echo "  ✅ Added 'cc' alias for Claude Code"
    else
        echo "  ✅ Claude Code alias already exists"
    fi
    
    # Copy Claude configuration files if they exist
    echo "- copy claude configuration files"
    CLAUDE_FILES_SOURCE="$(dirname "$1")/files/.claude"
    if [ -d "$CLAUDE_FILES_SOURCE" ]; then
        mkdir -p ~/.claude
        cp -r "$CLAUDE_FILES_SOURCE"/* ~/.claude/ 2>/dev/null || true
        echo "  ✅ Claude configuration files copied to ~/.claude/"
    else
        echo "  ℹ️  No Claude files found in machine configuration"
    fi
else
    echo "  ⚠️  Claude Code CLI installation failed"
    echo "     Try running: npm install -g @anthropic-ai/claude-code"
    echo "  📋 Continuing with installation (Claude Code CLI is optional)"
fi