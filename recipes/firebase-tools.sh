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
    echo "npm is not installed. Please install Node.js/npm first (run the nvm recipe)"
    exit 1
fi

# Install firebase-tools globally
npm install -g firebase-tools

echo "Firebase Tools installed successfully"
echo "You can now use 'firebase' command in your terminal"
echo "Run 'firebase login' to authenticate with your Firebase account"