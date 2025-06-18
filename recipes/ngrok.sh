#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install ngrok"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Download ngrok binary
wget -O ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz

# Extract and install
tar -xzf ngrok.tgz
sudo mv ngrok /usr/local/bin/

# Clean up
rm ngrok.tgz

# Link ngrok to your account
if [ -n "$NGROK_AUTHTOKEN" ] && [ "$NGROK_AUTHTOKEN" != "test-token" ]; then
    ngrok config add-authtoken $NGROK_AUTHTOKEN
else
    echo "Warning: NGROK_AUTHTOKEN not set or is test token, skipping auth setup"
fi
