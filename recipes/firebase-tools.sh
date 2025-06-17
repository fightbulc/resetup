#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install firebase-tools"

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "  ⚠️  npm is not installed - Firebase Tools requires Node.js/npm"
    echo "     To install Firebase Tools:"
    echo "     1. Run the 'nvm' recipe first to install Node.js"
    echo "     2. Then run the 'firebase-tools' recipe again"
    echo "  📋 Skipping Firebase Tools installation (dependency missing)"
    exit 0
fi

# Install firebase-tools globally
echo "  Installing Firebase Tools via npm..."
if npm install -g firebase-tools; then
    echo "  ✅ Firebase Tools installed successfully"
    echo "     You can now use 'firebase' command in your terminal"
    echo "     Run 'firebase login' to authenticate with your Firebase account"
else
    echo "  ⚠️  Firebase Tools installation failed"
    echo "     Try running: npm install -g firebase-tools"
    echo "  📋 Continuing with installation (Firebase Tools is optional)"
fi