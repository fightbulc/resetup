# Resetup

A simple bash-based tool to quickly set up development machines when you need something *right now* and don't have time to learn Ansible & Co.

## Table of Contents

- [Why Not Ansible?](#why-not-ansible)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Set Up Your Configuration](#set-up-your-configuration)
- [Commands](#commands)
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

**New to Resetup?** Get started:

```bash
# Clone and initialize
git clone https://github.com/your-username/resetup.git
cd resetup
./resetup init  # Create data directory with templates
./resetup recipes base git docker  # Install specific tools
```

**Already have Resetup configured?** Set up a new machine:

```bash
./resetup unpack  # Decrypts your config and installs everything
```

**Want specific tools only?**

```bash
./resetup recipes golang rust docker  # Install just these tools
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

**Core System:** `base` `ssh` `git`  
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
| `./resetup recipes [names]` | Install specific recipes |
| `./resetup clean` | Reset installation tracking |
| `./resetup refresh` | Update recipes and test them |

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
<summary>Updating and testing recipes</summary>

```bash
# Update all recipes and test them
./resetup refresh

# Test recipes in Docker
docker build -f Dockerfile.test -t resetup-test .
```

</details>

## Security

Your sensitive data is protected with AES-256 encryption. Only you have the password to decrypt it.

## License

MIT