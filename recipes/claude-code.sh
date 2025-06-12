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
    echo "npm is not installed. Please install Node.js/npm first (run the nvm recipe)"
    exit 1
fi

# Install claude-code globally
npm install -g @anthropic-ai/claude-code

echo "Claude Code CLI installed successfully"
echo "You can now use 'claude' command in your terminal"