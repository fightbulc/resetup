#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install jj (jujutsu version control)"

# Check if running in Docker/CI environment
if [ -f /.dockerenv ] || [ "$CI" = "true" ]; then
    echo "  Docker/CI environment detected, using binary installation method"

    # Download pre-built binary from GitHub releases
    JJ_VERSION="v0.33.0"
    JJ_URL="https://github.com/jj-vcs/jj/releases/download/${JJ_VERSION}/jj-${JJ_VERSION}-x86_64-unknown-linux-musl.tar.gz"

    # Create temp directory and download
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    echo "  Downloading JJ ${JJ_VERSION}..."
    if curl -L -o jj.tar.gz "$JJ_URL"; then
        tar -xzf jj.tar.gz

        # Install to user's local bin directory
        mkdir -p ~/.local/bin
        cp jj ~/.local/bin/jj
        chmod +x ~/.local/bin/jj

        # Add to PATH in bashrc if not already there
        if ! grep -q '~/.local/bin' ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# jj (jujutsu)" >> ~/.bashrc
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        fi

        # Make available in current session
        export PATH="$HOME/.local/bin:$PATH"

        echo "  JJ installed successfully via binary"
    else
        echo "  Failed to download JJ binary, skipping installation"
        cd /
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    cd /
    rm -rf "$TEMP_DIR"
else
    # Install via cargo (requires Rust)
    if command -v cargo &> /dev/null; then
        echo "  Installing JJ via cargo..."
        cargo install --locked jj-cli
        echo "  JJ installed successfully via cargo"
    else
        echo "  Rust/cargo not found, installing via binary..."

        # Fallback to binary installation
        JJ_VERSION="v0.33.0"
        JJ_URL="https://github.com/jj-vcs/jj/releases/download/${JJ_VERSION}/jj-${JJ_VERSION}-x86_64-unknown-linux-musl.tar.gz"

        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"

        if curl -L -o jj.tar.gz "$JJ_URL"; then
            tar -xzf jj.tar.gz

            mkdir -p ~/.local/bin
            cp jj ~/.local/bin/jj
            chmod +x ~/.local/bin/jj

            if ! grep -q '~/.local/bin' ~/.bashrc; then
                echo "" >> ~/.bashrc
                echo "# jj (jujutsu)" >> ~/.bashrc
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            fi

            export PATH="$HOME/.local/bin:$PATH"

            echo "  JJ installed successfully via binary"
        else
            echo "  Failed to download JJ binary, skipping installation"
            cd /
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        cd /
        rm -rf "$TEMP_DIR"
    fi
fi

# Configure JJ with user settings from master.cnf
echo "- configure jj"

# Set user configuration if variables are available
if [ -n "$GIT_USERNAME" ]; then
    ~/.local/bin/jj config set --user user.name "$GIT_USERNAME" || jj config set --user user.name "$GIT_USERNAME"
    echo "  Set user.name to: $GIT_USERNAME"
fi

if [ -n "$GIT_EMAIL" ]; then
    ~/.local/bin/jj config set --user user.email "$GIT_EMAIL" || jj config set --user user.email "$GIT_EMAIL"
    echo "  Set user.email to: $GIT_EMAIL"
fi

# Verify installation
if command -v jj &> /dev/null || command -v ~/.local/bin/jj &> /dev/null; then
    JJ_VERSION=$(jj --version 2>/dev/null || ~/.local/bin/jj --version 2>/dev/null)
    echo "  JJ installation verified: $JJ_VERSION"
else
    echo "  Warning: JJ installation could not be verified"
fi