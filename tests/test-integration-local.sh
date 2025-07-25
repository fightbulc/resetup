#!/usr/bin/env bash

set -e

echo "=== Local Integration Test Runner ==="
echo ""

# Build the test Docker image
echo "1. Building Docker test image..."
docker build -f ../tests/Dockerfile.test -t resetup-integration-test .. --quiet
echo "✅ Docker image built"

# Run integration tests in container
echo ""
echo "2. Running integration tests in Docker container..."
docker run --rm \
    -v "$(pwd)/..:/resetup" \
    -w /resetup \
    --user root \
    resetup-integration-test \
    bash -c '
        # Fix ownership for testuser
        chown -R testuser:testuser /resetup
        
        # Switch to testuser and run tests
        su - testuser -c "
            cd /resetup
            echo \"Setting up test environment...\"
            
            # Create test data structure in tests directory
            mkdir -p tests/.integration-local-test/data/config tests/.integration-local-test/data/files/.ssh
            
            # Use existing test data or create from template
            if [ -f \"tests/test-data/config/master.cnf\" ]; then
                cp tests/test-data/config/master.cnf tests/.integration-local-test/data/config/master.cnf
            else
                echo \"❌ No test data found\"
                exit 1
            fi
            
            # Create test SSH config
            cat > tests/.integration-local-test/data/files/.ssh/config << EOF
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_rsa
EOF
            
            # Create dummy SSH key (remove if exists to avoid prompt)
            rm -f tests/.integration-local-test/data/files/.ssh/id_ed25519 tests/.integration-local-test/data/files/.ssh/id_ed25519.pub
            ssh-keygen -t ed25519 -f tests/.integration-local-test/data/files/.ssh/id_ed25519 -N \"\" -C \"test@example.com\"
            
            echo \"✅ Test environment ready\"
            echo \"\"
            
            # Run the integration test
            echo \"Running integration tests...\"
            chmod +x tests/integration-test.sh
            ./tests/integration-test.sh
            
            # Clean up test data
            echo \"Cleaning up test data...\"
            rm -rf tests/.integration-local-test/
        "
    '

echo ""
echo "✅ Local integration tests completed successfully!"