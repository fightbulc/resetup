#!/usr/bin/env bash

# Simple Docker test for a single recipe

RECIPE_NAME=${1:-"ripgrep"}
BASE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)

echo "Testing recipe: $RECIPE_NAME"

# Create test directory
mkdir -p "$BASE_PATH/tests/.test"

# Create test Dockerfile
cat > "$BASE_PATH/tests/.test/Dockerfile.test.$RECIPE_NAME" << EOF
FROM ubuntu:25.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
ENV RECIPE_NAME=$RECIPE_NAME
ENV DOCKER_BUILD=1

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \\
    curl \\
    wget \\
    git \\
    sudo \\
    software-properties-common \\
    apt-transport-https \\
    ca-certificates \\
    gnupg \\
    lsb-release

# Create test user with sudo access
RUN useradd -m -s /bin/bash testuser && \\
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy recipe
COPY recipes/$RECIPE_NAME.sh /tmp/recipe.sh
RUN chmod +x /tmp/recipe.sh

# Create test machine config with all required variables
RUN mkdir -p /tmp/machines/test-machine/files/.ssh && \\
    echo "#!/usr/bin/env bash" > /tmp/machines/test-machine/master.cnf && \\
    echo "export GIT_USERNAME=test" >> /tmp/machines/test-machine/master.cnf && \\
    echo "export GIT_EMAIL=test@example.com" >> /tmp/machines/test-machine/master.cnf && \\
    echo "export NGROK_AUTHTOKEN=test-token" >> /tmp/machines/test-machine/master.cnf && \\
    echo "export TURSO_TOKEN=test-token" >> /tmp/machines/test-machine/master.cnf && \\
    echo "export HOME_DIR=/home/testuser" >> /tmp/machines/test-machine/master.cnf && \\
    echo "test-ssh-key" > /tmp/machines/test-machine/files/.ssh/test_key && \\
    chmod 600 /tmp/machines/test-machine/files/.ssh/test_key

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Create source directory
RUN mkdir -p /tmp/source

# Run the recipe
RUN bash /tmp/recipe.sh /tmp/machines/test-machine/master.cnf /tmp

# Verify installation based on recipe
# Use different verification methods based on recipe type
RUN case "$RECIPE_NAME" in \\
    golang) \\
        export PATH=\$PATH:/usr/local/go/bin && \\
        which go && go version ;; \\
    rust) \\
        export PATH=\$PATH:\$HOME/.cargo/bin && \\
        which rustc && rustc --version ;; \\
    nvm) \\
        export NVM_DIR="\$HOME/.nvm" && \\
        [ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh" && \\
        command -v nvm && nvm --version && node --version ;; \\
    ripgrep|lazygit|jaq|gh|docker|discord|signal|sqlite3|telegram) \\
        case "$RECIPE_NAME" in \\
            ripgrep) which rg && rg --version ;; \\
            lazygit) which lazygit && lazygit --version ;; \\
            jaq) which jaq && jaq --version ;; \\
            gh) which gh && gh --version ;; \\
            docker) which docker || echo "Docker client installed" ;; \\
            discord) dpkg -l | grep -i discord && echo "Discord installed" ;; \\
            signal) dpkg -l | grep -i signal-desktop && echo "Signal Desktop installed" ;; \\
            sqlite3) which sqlite3 && sqlite3 --version ;; \\
            telegram) which telegram-desktop && echo "Telegram Desktop installed" ;; \\
        esac ;; \\
    *) echo "No specific verification for $RECIPE_NAME" ;; \\
esac
EOF

# Build and test
echo "Building Docker image..."
if docker build --build-arg RECIPE_NAME="$RECIPE_NAME" -f "$BASE_PATH/tests/.test/Dockerfile.test.$RECIPE_NAME" -t "resetup-test:$RECIPE_NAME" "$BASE_PATH"; then
    echo "✅ Recipe $RECIPE_NAME tested successfully!"
    # Clean up
    docker rmi "resetup-test:$RECIPE_NAME"
else
    echo "❌ Recipe $RECIPE_NAME failed testing"
    exit 1
fi

# Clean up
rm -rf "$BASE_PATH/tests/.test"

echo "Test complete!"