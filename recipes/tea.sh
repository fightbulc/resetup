#!/usr/bin/env bash

# SOURCE CONFIG
. $1

# RUN TASK
echo "- install tea (Gitea CLI)"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Download the prebuilt binary for linux-amd64
echo "Downloading tea 0.10.1..."
wget "https://dl.gitea.com/tea/0.10.1/tea-0.10.1-linux-amd64" -O tea

# Make executable and install to /usr/local/bin
chmod +x tea
sudo install tea /usr/local/bin/

# Clean up
rm tea

popd
rm -rf "$TEMP_DIR"

# Configure tea login if GITEA_TOKEN is set
if [ -n "$GITEA_TOKEN" ]; then
    echo "Configuring tea login..."
    # Create tea config directory if it doesn't exist
    mkdir -p ~/.config/tea
    
    # Add login configuration
    tea login add \
        --url "https://gitea.lanu.team" \
        --name "te" \
        --token "$GITEA_TOKEN" \
        --insecure false \
        --user "" \
        --password "" \
        --ssh-key "" \
        --ssh-cert "" \
        --ssh-passphrase "" \
        --ssh-agent-key "" \
        --ssh-agent-principal ""
    
    # Set as default login
    tea login default te
    
    echo "tea login configured successfully"
else
    echo "Note: Set GITEA_TOKEN in master.cnf to configure tea login automatically"
fi

echo "tea installed successfully"