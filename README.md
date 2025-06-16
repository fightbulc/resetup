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

**New to Resetup?** Try it in 30 seconds:

```bash
# Clone and run a basic setup
git clone https://github.com/your-username/resetup.git
cd resetup
./scripts/recipes base git docker
```

**Already have Resetup configured?** Set up a new machine:

```bash
./unpack  # Decrypts your config and installs everything
```

**Want specific tools only?**

```bash
./scripts/recipes golang rust docker  # Install just these tools
```

## How It Works

Resetup uses "recipes" - simple scripts that install and configure tools. Each recipe:
- Installs a specific tool (like Docker or VS Code)
- Handles dependencies automatically
- Can be run individually or together

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
# 1. Put your config files in data/
mkdir -p data/config data/files/.ssh
echo 'export GIT_USERNAME="Your Name"' > data/config/master.cnf
echo 'export GIT_EMAIL="you@example.com"' >> data/config/master.cnf

# 2. Add SSH keys, dotfiles, etc.
cp ~/.ssh/id_rsa data/files/.ssh/

# 3. Encrypt everything
./pack
```

**Your config is stored securely** with AES-256 encryption. The `data.aes256` file contains all your sensitive information.

## Commands

| Command | What it does |
|---------|-------------|
| `./unpack` | Decrypt config and install everything |
| `./pack` | Encrypt your configuration |
| `./scripts/recipes [names]` | Install specific recipes |
| `./clean` | Reset installation tracking |
| `./refresh` | Update recipes and test them |

## Advanced Usage

<details>
<summary>Creating custom recipes</summary>

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

</details>

<details>
<summary>Updating and testing recipes</summary>

```bash
# Update all recipes and test them
./refresh

# Test recipes in Docker
docker build -f Dockerfile.test -t resetup-test .
```

</details>

## Security

Your sensitive data is protected with AES-256 encryption. Only you have the password to decrypt it.

## License

MIT