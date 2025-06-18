# Resetup

A simple bash-based tool to quickly set up development machines when you need something *right now* and don't have time to learn Ansible & Co.

## Table of Contents

- [Why Not Ansible?](#why-not-ansible)
- [Quick Start](#quick-start)
- [Multi-Machine Management](#multi-machine-management)
- [How It Works](#how-it-works)
- [Set Up Your Configuration](#set-up-your-configuration)
- [Commands](#commands)
- [Testing](#testing)
- [Advanced Usage](#advanced-usage)
- [Security](#security)
- [License](#license)

## Why Not Ansible?

Yes, Ansible is probably the "right" way to do infrastructure automation. But sometimes you just need to get a new machine running **today** without spending weeks learning proper configuration management.

**The kicker:** Since everything is encrypted, this can be a public repo. Walk up to any machine with internet and you're 5 minutes away from your full dev environment.

Resetup is for when you:
- Need to set up a new developer machine right now
- Just broke your existing machine and need to get back to work
- Want something dead simple (just bash scripts)
- Don't want to learn Ansible/Chef/Puppet yet
- Have a few machines to manage, not hundreds

It's not the most pro solution, but it works and gets you productive fast.

## Quick Start

**One-line installation:**

```bash
# Install resetup automatically
curl -fsSL https://raw.githubusercontent.com/fightbulc/resetup/main/install.sh | bash
```

**Manual installation:**

```bash
# Clone and initialize
git clone https://github.com/fightbulc/resetup.git
cd resetup
```

**First time setup:**

```bash
# Create a machine-specific configuration
./resetup init laptop                    # Create 'laptop' machine config
# Edit machines/laptop/master.cnf with your settings
# Customize machines/laptop/cookbook.yaml with desired recipes
./resetup pack laptop                    # Encrypt your configuration
./resetup laptop                         # Set up your laptop
```

**Already have Resetup configured?** Set up a new machine:

```bash
./resetup laptop                         # Unpack and set up laptop machine
./resetup server                         # Unpack and set up server machine
./resetup laptop -y                      # Auto-confirm all recipes (no prompts)
```

**Manage multiple machines:**

```bash
./resetup list                           # Show available machines
./resetup clone laptop server            # Copy laptop config to server
./resetup pack server                    # Encrypt server configuration
```

**Want specific tools only?**

```bash
./resetup recipes laptop golang rust     # Install specific recipes on laptop
./resetup recipes server docker -f       # Force reinstall docker on server
./resetup recipes laptop base -y -f      # Auto-confirm and force reinstall
```

## Multi-Machine Management

Resetup supports managing configurations for multiple machines (laptop, server, dev, prod, etc.). Each machine has its own configuration, recipes list, and encrypted storage.

### Machine Configuration Structure

```
resetup/
├── machines/
│   ├── laptop/
│   │   ├── master.cnf          # Machine-specific environment variables
│   │   ├── cookbook.yaml       # List of recipes to install on this machine
│   │   ├── files/              # Machine-specific files (SSH keys, dotfiles)
│   │   └── .installed_recipes  # Per-machine installation tracking
│   ├── laptop.aes256           # Encrypted laptop configuration
│   ├── server/
│   │   ├── master.cnf          # Different config for server
│   │   ├── cookbook.yaml       # Different recipes for server
│   │   ├── files/
│   │   └── .installed_recipes
│   ├── server.aes256           # Encrypted server configuration
│   ├── dev/
│   │   ├── master.cnf
│   │   ├── cookbook.yaml
│   │   ├── files/
│   │   └── .installed_recipes
│   └── dev.aes256              # Encrypted dev configuration
```

### Core Concepts

**Machine-Specific Configurations:**
- Each machine has its own `master.cnf` with different environment variables
- Different SSH keys, API tokens, and settings per machine
- Separate installation tracking prevents conflicts

**Recipe Cookbooks:**
- Each machine has a `cookbook.yaml` that lists which recipes to install
- Laptop might have GUI tools, server might have only CLI tools
- Easily customize what gets installed on each machine type

**Separate Encryption:**
- Each machine gets its own encrypted file (`machines/[machine].aes256`)
- Different passwords per machine for enhanced security
- Share common configurations while keeping secrets separate

### Multi-Machine Workflows

**Set up different machine types:**

```bash
# Development laptop
./resetup init laptop
# Edit machines/laptop/cookbook.yaml to comment out unwanted tools
./resetup pack laptop

# Production server  
./resetup init server
# Edit machines/server/cookbook.yaml to comment out GUI tools (bruno, cursor, obsidian)
./resetup pack server

# Development server
./resetup clone laptop dev-server
# Edit machines/dev-server/cookbook.yaml to comment out GUI tools
./resetup pack dev-server
```

**Deploy to machines:**

```bash
# Set up your laptop
./resetup laptop

# Set up your server (on the server machine)
./resetup server

# Set up your dev server
./resetup dev-server
```

**Manage configurations:**

```bash
# See all available machines
./resetup list

# Clone laptop config for a new team member
./resetup clone laptop teammate-laptop

# Remove old machine configuration
./resetup delete old-laptop

# Install specific tools on specific machines
./resetup recipes laptop bruno cursor      # Add tools to laptop
./resetup recipes server golang -f         # Force reinstall golang on server
```

### Benefits of Multi-Machine Setup

- **Role-based configurations**: Different tools for different machine roles
- **Environment isolation**: Dev, staging, and prod can have different settings
- **Team collaboration**: Share machine templates while keeping personal secrets
- **Selective deployment**: Only install what each machine needs
- **Easy migration**: Clone and modify configurations for new machines

## How It Works

Resetup uses "recipes" - simple scripts that install and configure tools. Each recipe:
- Installs a specific tool (like Docker or VS Code)
- Handles dependencies automatically
- Can be run individually or together
- Has access to your machine-specific configuration variables from `master.cnf`

**Configuration System:** Each machine has its own `machines/[machine]/master.cnf` file containing environment variables that recipes can use. For example, if you set `export GIT_USERNAME="John Doe"` in your laptop's master.cnf, recipes will use `$GIT_USERNAME` to configure git with your name automatically.

**Recipe Cookbooks:** Each machine has a `cookbook.yaml` file that specifies which recipes to install. This allows different machines to have different tools - your laptop might include GUI applications while your server only installs CLI tools.

**Popular recipes:** `base` `git` `docker` `golang` `rust` `obsidian`

<details>
<summary>View all available recipes</summary>

**Core System:** `base` `ssh` `git` `flatpak`  
**Languages:** `rust` `golang` `deno` `nvm`  
**Dev Tools:** `docker` `gh` `ripgrep` `fzf` `lazygit` `bruno` `cursor` `claude-code` `beekeeper-studio`  
**Productivity:** `obsidian` `1password`  
**Terminal:** `ghostty` `lf` `cascadia-font`  
**Utilities:** `chrome` `slack` `rustdesk` `youtube-downloader` `ngrok` `turso`

</details>

## Set Up Your Configuration

**Create your first machine:**

```bash
# 1. Initialize machine-specific configuration
./resetup init laptop

# 2. Edit your machine configuration
vim machines/laptop/master.cnf    # Add your settings

# 3. Customize which recipes to install
vim machines/laptop/cookbook.yaml # Comment/uncomment recipes for this machine

# 4. Add SSH keys, dotfiles, etc.
cp ~/.ssh/id_rsa machines/laptop/files/.ssh/

# 5. Encrypt everything
./resetup pack laptop
```

**Your config is stored securely** with AES-256 encryption. The `machines/laptop.aes256` file contains all your sensitive information for that machine.

### Configuration Files Explained

**master.cnf:** Contains environment variables that recipes use for automatic configuration. Each machine has its own copy with machine-specific settings:
- `$GIT_USERNAME` and `$GIT_EMAIL` - Automatically configure git
- `$GITHUB_TOKEN` - Set up GitHub CLI authentication  
- `$OPENAI_API_KEY` - Configure AI tools
- `$EDITOR` - Set your preferred editor
- Any custom variables you add

**cookbook.yaml:** Lists which recipes to install on this machine. When you run `resetup init`, ALL available recipes are included by default, organized by category. Simply comment out (prefix with `#`) recipes you don't want on this machine. Example:
```yaml
recipes:
  # Core system recipes (recommended for all machines)
  - base
  - git
  - ssh
  
  # Development tools
  - docker
  - golang
  - rust
  # - cursor       # Comment out to skip this recipe
  
  # Productivity tools  
  - obsidian
  - bruno
  # - flatpak      # Comment out to skip this recipe
```

**Recipe automation example:** The git recipe automatically configures git with your details:
```bash
#!/usr/bin/env bash
. $1  # Sources master.cnf, making variables available

echo "- setup git"
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
```

This means recipes can install AND configure tools with your personal settings automatically.


## Commands

### Core Commands

| Command | What it does |
|---------|-------------|
| `./resetup init <machine>` | Initialize machine-specific configuration |
| `./resetup pack <machine>` | Encrypt machine configuration |
| `./resetup <machine>` | Unpack and set up machine (shortcut for `unpack <machine>`) |
| `./resetup unpack <machine>` | Decrypt config and install everything for machine |
| `./resetup <machine> -y` | Shortcut for `unpack <machine> -y` (auto-confirm) |

### Recipe Management

| Command | What it does |
|---------|-------------|
| `./resetup recipes <machine> [names]` | Install specific recipes on machine |
| `./resetup recipes <machine> [names] -f` | Force reinstall recipes (bypass "already installed" check) |
| `./resetup recipes <machine> [names] -y` | Auto-confirm all prompts during recipe installation |

### Machine Management

| Command | What it does |
|---------|-------------|
| `./resetup list` | Show all available machines and their status |
| `./resetup clone <src> <dst>` | Clone source machine configuration to destination |
| `./resetup delete <machine>` | Delete machine configuration and encrypted files |

### Maintenance

| Command | What it does |
|---------|-------------|
| `./resetup clean <machine>` | Reset installation tracking for machine |
| `./resetup refresh <machine>` | Update recipes and test them |
| `./resetup docker` | Start interactive Docker container for testing |

### Examples

**Machine-specific operations:**
```bash
./resetup init laptop                    # Create laptop machine
./resetup pack laptop                    # Encrypt laptop config  
./resetup laptop                         # Set up laptop
./resetup laptop -y                      # Set up laptop with auto-confirm
./resetup recipes laptop golang rust     # Install specific recipes on laptop
./resetup clean laptop                   # Reset laptop installation tracking
```

**Multi-machine management:**
```bash
./resetup list                           # Show all machines
./resetup clone laptop server            # Copy laptop config to server
./resetup delete old-laptop              # Remove old machine
```


### Recipe Options

- **`-f` (force)**: Reinstall recipes even if they're already installed
- **`-y` (yes)**: Auto-confirm all prompts without user interaction
- **Combine flags**: Use `-y -f` together for automated force reinstalls

### AppImage Management

Some recipes download AppImages to `~/Downloads` instead of installing them system-wide. This gives you more control over application versions and makes them easier to manage.

**AppImage recipes:** `bruno` `cursor` `beekeeper-studio`

**Important AppImage Notes:**
- **Bruno**: Includes `--no-sandbox` flag by default, runs properly out of the box
- **Cursor**: Does NOT include `--no-sandbox` flag by default, may need manual configuration
- **Beekeeper Studio**: Modern SQL client, runs properly without additional flags
- **Gear Lever**: Use the `flatpak` recipe to install Gear Lever for AppImage integration
- When integrating AppImages with Gear Lever, add `--no-sandbox` flag for apps that don't support proper sandboxing (like Cursor)

**Example usage:**
```bash
# Download AppImages to specific machine
./resetup recipes laptop bruno cursor beekeeper-studio

# Install Gear Lever for AppImage management
./resetup recipes laptop flatpak

# Run Bruno (works by default)
~/Downloads/bruno.AppImage

# Run Cursor with proper sandbox handling
~/Downloads/cursor.AppImage --no-sandbox

# Run Beekeeper Studio
~/Downloads/beekeeper-studio.AppImage

```

## Testing

Resetup includes a comprehensive test suite to ensure recipes work correctly and the system is reliable.

### Running Tests

**Run all tests:**
```bash
# Run tests exactly as they run in GitHub Actions
./tests/run-all-tests.sh
```

**Run individual test categories:**
```bash
# Test YAML configuration and dependencies
python3 tests/check-dependencies.py
./tests/test-dependencies.sh

# Test encryption/decryption system
CI=true ./tests/integration-test.sh

# Test clean command functionality
./tests/test-clean.sh

# Test individual recipes in Docker
./tests/test-recipe.sh golang
./tests/test-recipe.sh git
```

### What Tests Cover

**1. Configuration Validation**
- YAML syntax validation for `recipes.yaml`
- All recipe script files exist
- Circular dependency detection
- Dependency resolution logic

**2. Recipe Testing**
- Individual recipes install correctly in clean Docker containers
- Recipes can access configuration variables from `master.cnf`
- Dependencies are resolved in correct order
- Recipes work with test data structure

**3. Encryption System**
- Data encryption with AES-256
- Decryption and data integrity
- Password-based encryption workflows

**4. Command Interface**
- Unified `resetup` command works correctly
- All subcommands (`init`, `pack`, `unpack`, `recipes`, `clean`, `refresh`) exist
- Help system functions properly
- Script locations are correct

**5. Integration Testing**
- End-to-end workflow from init to encryption
- Test data generation and cleanup
- Cross-component compatibility

**6. Clean Command**
- Installation tracking removal
- Idempotent operations
- Working directory preservation

### Test Data

Tests create their own isolated test data and never interfere with real user configurations:
- Integration tests create temporary test data in `.integration-test/`
- Recipe tests generate fresh `test-data/` directories
- All test data is cleaned up automatically
- Tests use `CI=true` environment variable to skip Docker tests when needed

### Continuous Integration

GitHub Actions automatically runs tests on every push and pull request:
- **validate-yaml**: Validates configuration files
- **test-recipes**: Tests individual recipes in Docker containers
- **test-encryption**: Tests encryption/decryption functionality  
- **test-dependencies**: Validates dependency resolution
- **integration-test**: End-to-end workflow testing

Tests are designed to work in both local development and CI environments.

For detailed testing information, see [tests/TESTING.md](tests/TESTING.md).

## Advanced Usage

<details>
<summary>Creating custom recipes</summary>

1. Create a script in `recipes/` directory:
   ```bash
   #!/usr/bin/env bash
   . $1  # Source master config (makes variables like $GIT_USERNAME available)
   
   echo "- install myapp"
   
   # Install the application
   sudo apt install myapp
   
   # Configure using variables from master.cnf
   myapp config --username "$GIT_USERNAME"
   myapp config --email "$GIT_EMAIL"
   ```

2. Add entry to `recipes.yaml`:
   ```yaml
   - name: myapp
     description: "My application"
     script: myapp.sh
     dependencies: [base]
     tags: [productivity]
   ```

</details>

<details>
<summary>Testing in Docker environment</summary>

Resetup provides a Docker environment for safe testing without affecting your host system:

```bash
# Start interactive Docker container with clean Ubuntu 25.04
./resetup docker

# Inside the container, you can test resetup safely:
./resetup init test-machine
./resetup pack test-machine
./resetup test-machine -y
```

**What the Docker environment provides:**
- Fresh Ubuntu 25.04 environment
- Latest resetup repository from GitHub
- All necessary dependencies (git, curl, openssl, yq)
- Non-root user with sudo access
- Clean testing environment that doesn't affect your host

**Use cases:**
- Test resetup on a clean system
- Develop and debug recipes safely
- Verify installation process before running on real machines
- Test multi-machine configurations safely

</details>

<details>
<summary>Multi-machine testing and development</summary>

```bash
# Test different machine configurations
./resetup init dev-test
./resetup init prod-test

# Create different cookbook configurations for testing
echo "recipes: [base, git, docker]" > machines/dev-test/cookbook.yaml
echo "recipes: [base, ssh, docker, golang]" > machines/prod-test/cookbook.yaml

# Test machine cloning
./resetup clone dev-test staging-test

# Test recipe installation on specific machines
./resetup recipes dev-test golang rust -y
./resetup recipes prod-test nginx -f

# Clean up test machines
./resetup delete dev-test
./resetup delete prod-test
./resetup delete staging-test
```

**Multi-machine development workflow:**
- Create test machines for different scenarios
- Test recipe combinations without affecting real configurations
- Verify machine cloning and management functionality
- Validate cookbook.yaml configurations
- Test different encryption scenarios

</details>

<details>
<summary>Updating and testing recipes</summary>

```bash
# Update all recipes and test them
./resetup refresh

# Test specific recipes in isolation (automated testing)
./tests/test-recipe.sh golang
./tests/test-recipe.sh docker

# Force reinstall recipes on specific machines for testing
./resetup recipes laptop docker -f
./resetup recipes server golang -f

# Test recipes on different machine types
./resetup recipes dev-machine bruno cursor    # GUI tools on dev machine
./resetup recipes prod-server docker golang   # Server tools on production

```

**Recipe testing strategies:**
- Test recipes on different machine configurations
- Verify recipe dependencies work across machine types
- Test force reinstallation scenarios
- Validate recipe cookbook integration
- Use Docker environment for isolated testing

</details>

## Security

Your sensitive data is protected with AES-256 encryption. Each machine configuration is encrypted separately with its own password.

### Multi-Machine Security Benefits

- **Isolation**: Each machine has its own encrypted file (`[machine].aes256`)
- **Selective Access**: You can choose different passwords for different machines
- **Risk Mitigation**: Compromise of one machine's password doesn't affect others
- **Role-based Security**: Production servers can have stronger passwords than development machines

### Encryption Files

- `machines/laptop.aes256` - Encrypted laptop configuration
- `machines/server.aes256` - Encrypted server configuration  
- `machines/dev.aes256` - Encrypted development configuration

### Best Practices

- Use strong, unique passwords for each machine
- Keep production machine passwords separate from development
- Regularly rotate passwords for sensitive environments
- Store encrypted files in version control safely (passwords are not stored)

## License

MIT