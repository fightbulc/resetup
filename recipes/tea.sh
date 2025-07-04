#!/usr/bin/env bash

# SOURCE CONFIG
. $1

# RUN TASK
echo "- install tea (Gitea CLI)"

pushd $2/source

# Download the prebuilt binary for linux-amd64
echo "Downloading tea 0.10.1..."
wget "https://dl.gitea.com/tea/0.10.1/tea-0.10.1-linux-amd64" -O tea

# Make executable and install to /usr/local/bin
chmod +x tea
sudo install tea /usr/local/bin/

# Clean up
rm tea

popd

echo "tea installed successfully"