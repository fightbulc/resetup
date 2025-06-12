# Resetup - Automated System Configuration

A secure, modular system for quickly setting up a new development machine with all your tools and configurations.

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
  - [First Time Setup](#first-time-setup)
  - [Setting Up a New Machine](#setting-up-a-new-machine)
- [Recipe System](#recipe-system)
  - [Available Recipes](#available-recipes)
- [Configuration Structure](#configuration-structure)
  - [Master Configuration](#master-configuration)
- [Commands](#commands)
- [Updating Recipes](#updating-recipes)
- [Creating New Recipes](#creating-new-recipes)
- [Security](#security)
- [Development](#development)
  - [Testing Recipes](#testing-recipes)
  - [Contributing](#contributing)
- [License](#license)

## Features

- 🔐 **Encrypted Configuration** - Sensitive data (SSH keys, API tokens) stored with AES-256 encryption
- 📦 **Modular Recipes** - Each tool/configuration is a separate recipe
- 🔗 **Dependency Management** - Automatically installs dependencies in the correct order
- 🏷️ **Tagged Organization** - Recipes organized by categories and tags
- 🐳 **Docker-based Testing** - Test recipe updates in isolated containers
- ✨ **User Control** - Choose which recipes to install

## Quick Start

### First Time Setup

1. Clone this repository
2. Place your configuration in `data/` directory
3. Encrypt your configuration:
   ```bash
   ./pack
   ```

### Setting Up a New Machine

```bash
# Decrypt configuration and run all recipes
./unpack

# Or run specific recipes
./scripts/recipes docker
./scripts/recipes golang
```

## Recipe System

Recipes are defined in `recipes.yaml` with:
- **Dependencies** - Other recipes that must be installed first
- **Tags** - Categories for organization (development, productivity, etc.)
- **Script** - The installation script in `recipes/` directory

### Available Recipes

#### Core System
- `base` - Essential system packages
- `ssh` - SSH configuration
- `git` - Git setup with personal config

#### Development Languages
- `rust` - Rust programming language
- `golang` - Go programming language  
- `deno` - Deno JavaScript/TypeScript runtime
- `nvm` - Node Version Manager

#### Development Tools
- `docker` - Container platform
- `gh` - GitHub CLI
- `ripgrep` - Fast file search
- `fzf` - Fuzzy finder
- `lazygit` - Terminal UI for Git
- `bruno` - API testing tool
- `cursor` - AI-powered code editor
- `helix` - Modal text editor
- `claude-code` - Claude AI CLI assistant

#### Productivity
- `obsidian` - Knowledge management
- `clickup` - Project management
- `1password` - Password manager

#### Terminal
- `ghostty` - GPU-accelerated terminal
- `lf` - Terminal file manager
- `cascadia-font` - Cascadia Code Nerd Font

#### Utilities
- `chrome` - Web browser
- `slack` - Team communication
- `rustdesk` - Remote desktop
- `youtube-downloader` - Download videos
- `ngrok` - Localhost tunneling
- `turso` - Edge database

## Configuration Structure

```
data/
├── config/
│   └── master.cnf    # Environment variables and secrets
└── files/            # Configuration files
    ├── .ssh/         # SSH keys
    └── ...           # Other configs
```

### Master Configuration

The `master.cnf` file contains environment variables:
```bash
export GIT_USERNAME="Your Name"
export GIT_EMAIL="your.email@example.com"
export API_TOKEN="your-api-token"
# ... other configuration
```

## Commands

### `./unpack`
Decrypt configuration files and run the installation process.

### `./pack`
Encrypt configuration files for secure storage.

### `./scripts/recipes [recipe-name]`
Install specific recipes or all recipes if no name provided.

### `./clean`
Remove all installed receipts and reset the system to a clean state. This removes the tracking of which recipes have been installed, allowing you to start fresh.

```bash
# Remove all receipt tracking
./clean
```

### `./refresh`
Update recipe scripts and run tests to ensure compatibility. Checks for package updates across all recipes, tests them in Docker containers, and commits changes if tests pass.

## Updating Recipes

Use the refresh command to check for package updates:

```bash
./refresh
```

This will:
1. Check each recipe for updates
2. Test changes in Docker containers
3. Commit updates if tests pass

## Creating New Recipes

1. Create a script in `recipes/` directory:
   ```bash
   #!/usr/bin/env bash
   . $1  # Source master config
   
   echo "- install myapp"
   # Installation commands here
   ```

2. Add entry to `recipes.yaml`:
   ```yaml
   - name: myapp
     description: "My application"
     script: myapp.sh
     dependencies: [base]
     tags: [productivity]
   ```

## Security

- Configuration data encrypted with OpenSSL AES-256
- Password required for encryption/decryption
- Sensitive files never committed to repository

## Development

### Testing Recipes

Recipes can be tested in Docker:
```bash
docker build -f Dockerfile.test -t resetup-test .
```

### Contributing

1. Create new branch
2. Add/modify recipes
3. Test changes
4. Submit pull request

## License

MIT