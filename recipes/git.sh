#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup git"

git config --global user.name "$GIT_USERNAME"
git config --global user.email $GIT_EMAIL
git config --global init.defaultBranch main

# Test SSH connectivity to GitHub (non-fatal)
if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
    echo "Testing SSH connection to GitHub..."
    ssh -o "StrictHostKeyChecking no" -T git@github.com || true
else
    echo "No SSH keys found, skipping GitHub connectivity test"
fi

#
# CLONE REPOSITORIES
#

# Check if repositories.yml exists in the machine configuration
MACHINE_DIR=$(dirname "$1")
REPOSITORIES_FILE="$MACHINE_DIR/files/repositories.yml"

if [ -f "$REPOSITORIES_FILE" ]; then
    echo "- cloning repositories from $REPOSITORIES_FILE"
    
    # Check if yq is available for YAML parsing
    if ! command -v yq &> /dev/null; then
        echo "Warning: yq not found, skipping repository cloning"
        echo "Install yq to enable automatic repository cloning"
        exit 0
    fi
    
    # Get base directory from config, default to ~/Buildspace
    BASE_DIR=$(yq eval '.config.base_directory // "~/Buildspace"' "$REPOSITORIES_FILE")
    BASE_DIR="${BASE_DIR/#\~/$HOME}"  # Expand ~ to home directory
    
    # Check if we should create org directories
    CREATE_ORG_DIRS=$(yq eval '.config.create_org_directories // true' "$REPOSITORIES_FILE")
    
    # Check if we should skip existing repositories
    SKIP_EXISTING=$(yq eval '.config.skip_existing // true' "$REPOSITORIES_FILE")
    
    # Get default branch
    DEFAULT_BRANCH=$(yq eval '.config.default_branch // "main"' "$REPOSITORIES_FILE")
    
    # Create base directory if it doesn't exist
    mkdir -p "$BASE_DIR"
    
    # Process each organization
    for org in $(yq eval '.repositories | keys | .[]' "$REPOSITORIES_FILE"); do
        echo "Processing organization: $org"
        
        # Create organization directory if enabled
        if [ "$CREATE_ORG_DIRS" = "true" ]; then
            ORG_DIR="$BASE_DIR/$org"
            mkdir -p "$ORG_DIR"
        else
            ORG_DIR="$BASE_DIR"
        fi
        
        # Process each repository in the organization
        repo_count=$(yq eval ".repositories.$org | length" "$REPOSITORIES_FILE")
        for ((i=0; i<repo_count; i++)); do
            # Extract repository details
            REPO_NAME=$(yq eval ".repositories.$org[$i].name" "$REPOSITORIES_FILE")
            REPO_URL=$(yq eval ".repositories.$org[$i].url" "$REPOSITORIES_FILE")
            REPO_DIR=$(yq eval ".repositories.$org[$i].directory // .repositories.$org[$i].name" "$REPOSITORIES_FILE")
            REPO_BRANCH=$(yq eval ".repositories.$org[$i].branch // \"$DEFAULT_BRANCH\"" "$REPOSITORIES_FILE")
            
            CLONE_PATH="$ORG_DIR/$REPO_DIR"
            
            # Skip if repository already exists and skip_existing is true
            if [ "$SKIP_EXISTING" = "true" ] && [ -d "$CLONE_PATH" ]; then
                echo "  - $REPO_NAME: already exists, skipping"
                continue
            fi
            
            echo "  - cloning $REPO_NAME to $CLONE_PATH"
            
            # Clone the repository
            if git clone "$REPO_URL" "$CLONE_PATH"; then
                echo "    ✓ successfully cloned $REPO_NAME"
                
                # Checkout specific branch if not main/master
                if [ "$REPO_BRANCH" != "main" ] && [ "$REPO_BRANCH" != "master" ]; then
                    cd "$CLONE_PATH"
                    git checkout "$REPO_BRANCH" || echo "    Warning: failed to checkout branch $REPO_BRANCH"
                    cd - > /dev/null
                fi
                
                # Apply git config if specified
                if yq eval ".config.git_config.$org" "$REPOSITORIES_FILE" | grep -q "user.email"; then
                    USER_EMAIL=$(yq eval ".config.git_config.$org.\"user.email\"" "$REPOSITORIES_FILE")
                    if [ "$USER_EMAIL" != "null" ]; then
                        cd "$CLONE_PATH"
                        git config user.email "$USER_EMAIL"
                        echo "    ✓ set user.email to $USER_EMAIL for $REPO_NAME"
                        cd - > /dev/null
                    fi
                fi
                
                if yq eval ".config.git_config.$org" "$REPOSITORIES_FILE" | grep -q "user.name"; then
                    USER_NAME=$(yq eval ".config.git_config.$org.\"user.name\"" "$REPOSITORIES_FILE")
                    if [ "$USER_NAME" != "null" ]; then
                        cd "$CLONE_PATH"
                        git config user.name "$USER_NAME"
                        echo "    ✓ set user.name to $USER_NAME for $REPO_NAME"
                        cd - > /dev/null
                    fi
                fi
                
            else
                echo "    ✗ failed to clone $REPO_NAME"
            fi
        done
    done
    
    echo "- repository cloning completed"
else
    echo "- no repositories.yml found, skipping repository cloning"
fi