#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install golang"

TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR"

# Get the latest Go version
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)

# Download Go
wget -cO go.tar.gz "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"

# Remove any existing Go installation
sudo rm -rf /usr/local/go

# Extract and install
sudo tar -C /usr/local -xzf go.tar.gz

# Clean up
rm go.tar.gz

popd
rm -rf "$TEMP_DIR"

# Add Go to PATH in .bashrc if not already there
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Go programming language" >> ~/.bashrc
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HOME/go/bin" >> ~/.bashrc
fi

# Create go workspace directory
mkdir -p ~/go/{bin,src,pkg}

# Install golangci-lint
echo "- install golangci-lint"
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

echo "Go installed successfully"
echo "Please run 'source ~/.bashrc' or restart your terminal to update PATH"