# Resetup

A simple bash-based tool to quickly set up development machines when you need something *right now* and don't have time to learn Ansible & Co.

## Table of Contents

- [Why Not Ansible?](#why-not-ansible)
- [Quick Start](#quick-start)
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
./resetup init  # Create data directory with templates
./resetup recipes base git docker  # Install specific tools
```

**Already have Resetup configured?** Set up a new machine:

```bash
./resetup unpack     # Decrypts your config and installs everything
./resetup unpack -y  # Auto-confirm all recipes (no prompts)
./resetup -y         # Shortcut for 'unpack -y'
```

**Want specific tools only?**

```bash
./resetup recipes golang rust docker    # Install just these tools
./resetup recipes cursor -f             # Force reinstall cursor even if already installed
./resetup recipes base docker -y -f     # Auto-confirm and force reinstall
```

## How It Works

Resetup uses "recipes" - simple scripts that install and configure tools. Each recipe:
- Installs a specific tool (like Docker or VS Code)
- Handles dependencies automatically
- Can be run individually or together
- Has access to your configuration variables from `master.cnf`

**Configuration System:** The `data/config/master.cnf` file contains environment variables that recipes can use. For example, if you set `export GIT_USERNAME="John Doe"` in master.cnf, recipes can use `$GIT_USERNAME` to configure git with your name automatically.

**Popular recipes:** `base` `git` `docker` `golang` `rust` `cursor` `obsidian`

<details>
<summary>View all available recipes</summary>

**Core System:** `base` `ssh` `git` `flatpak`  
**Languages:** `rust` `golang` `deno` `nvm`  
**Dev Tools:** `docker` `gh` `ripgrep` `fzf` `lazygit` `bruno` `cursor` `helix` `claude-code`  
**Productivity:** `obsidian` `clickup` `1password`  
**Terminal:** `ghostty` `lf` `cascadia-font`  
**Utilities:** `chrome` `slack` `rustdesk` `youtube-downloader` `ngrok` `turso`

</details>

## Set Up Your Configuration

**First time?** Create your configuration:

```bash
# 1. Initialize data directory
./resetup init

# 2. Edit your configuration
vim data/config/master.cnf  # Add your settings

# 3. Add SSH keys, dotfiles, etc.
cp ~/.ssh/id_rsa data/files/.ssh/

# 4. Encrypt everything
./resetup pack
```

**Your config is stored securely** with AES-256 encryption. The `data.aes256` file contains all your sensitive information.

**How master.cnf works:** This file contains environment variables that recipes use for automatic configuration. When you run recipes, they source this file and can use variables like:
- `$GIT_USERNAME` and `$GIT_EMAIL` - Automatically configure git
- `$GITHUB_TOKEN` - Set up GitHub CLI authentication  
- `$OPENAI_API_KEY` - Configure AI tools
- `$EDITOR` - Set your preferred editor
- Any custom variables you add

**Example:** The git recipe automatically configures git with your details:
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

| Command | What it does |
|---------|-------------|
| `./resetup init` | Initialize data directory with templates |
| `./resetup pack` | Encrypt your configuration |
| `./resetup unpack` | Decrypt config and install everything |
| `./resetup unpack -y` | Auto-confirm all recipes during installation |
| `./resetup -y` | Shortcut for `unpack -y` |
| `./resetup recipes [names]` | Install specific recipes |
| `./resetup recipes [names] -f` | Force reinstall recipes (bypass "already installed" check) |
| `./resetup recipes [names] -y` | Auto-confirm all prompts during recipe installation |
| `./resetup clean` | Reset installation tracking |
| `./resetup refresh` | Update recipes and test them |
| `./resetup docker` | Start interactive Docker container for testing |

### Recipe Options

- **`-f` (force)**: Reinstall recipes even if they're already installed
- **`-y` (yes)**: Auto-confirm all prompts without user interaction
- **Combine flags**: Use `-y -f` together for automated force reinstalls

### AppImage Management

Some recipes download AppImages to `~/Downloads` instead of installing them system-wide. This gives you more control over application versions and makes them easier to manage.

**AppImage recipes:** `bruno` `cursor`

**Important AppImage Notes:**
- **Bruno**: Includes `--no-sandbox` flag by default, runs properly out of the box
- **Cursor**: Does NOT include `--no-sandbox` flag by default, may need manual configuration
- **Gear Lever**: Use the `flatpak` recipe to install Gear Lever for AppImage integration
- When integrating AppImages with Gear Lever, add `--no-sandbox` flag for apps that don't support proper sandboxing (like Cursor)

**Example usage:**
```bash
# Download AppImages
./resetup recipes bruno cursor

# Install Gear Lever for AppImage management
./resetup recipes flatpak

# Run Bruno (works by default)
~/Downloads/bruno.AppImage

# Run Cursor with proper sandbox handling
~/Downloads/cursor.AppImage --no-sandbox
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
./resetup init
./resetup pack
./resetup unpack -y
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

</details>

<details>
<summary>Updating and testing recipes</summary>

```bash
# Update all recipes and test them
./resetup refresh

# Test specific recipes in isolation (automated testing)
./tests/test-recipe.sh golang
./tests/test-recipe.sh docker

# Force reinstall a recipe for testing
./resetup recipes docker -f
```

</details>

## Security

Your sensitive data is protected with AES-256 encryption. Only you have the password to decrypt it.

## License

MIT