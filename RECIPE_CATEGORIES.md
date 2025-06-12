# Recipe Categories and Dependencies

## Installation Order & Dependencies

The system ensures proper installation order through dependencies:

### 🎯 Level 0: Core Foundation
```
base
└── Essential system packages (curl, wget, git, build-essential, etc.)
```

### 🔧 Level 1: Direct Dependencies on Base
Most recipes depend only on `base` and can be installed in any order after base:

#### System & Security
- `ssh` - SSH key configuration
- `1password` - Password management

#### Programming Languages
- `rust` - Rust and Cargo
- `golang` - Go language
- `nvm` - Node.js via Node Version Manager
- `deno` - Deno runtime

#### Development Tools
- `git` - Git configuration
- `docker` - Container platform
- `gh` - GitHub CLI
- `ngrok` - Localhost tunneling

#### CLI Productivity
- `fzf` - Fuzzy finder
- `ripgrep` - Fast search
- `jaq` - JSON processor
- `lf` - File manager

#### Editors & IDEs
- `cursor` - AI-powered editor
- `helix` - Modal editor
- `bruno` - API client

#### Applications
- `chrome` - Browser
- `obsidian` - Notes
- `slack` - Communication
- `clickup` - Project management
- `ghostty` - Terminal emulator

#### Fonts & Customization
- `cascadia-font` - Nerd Font

#### Database Tools
- `firefoo` - Firebase client
- `turso` - Edge database

#### AI Tools
- `claude-code` - Claude CLI

#### Utilities
- `rustdesk` - Remote desktop
- `youtube-downloader` - Media downloader

### 🔗 Level 2: Secondary Dependencies
These recipes depend on Level 1 recipes:

```
git
└── lazygit (Terminal UI for Git)

rust
└── gthmb (GitHub TUI)
```

## How Dependencies Work

1. **Automatic Resolution**: When you install a recipe, all its dependencies are installed first
   ```bash
   ./scripts/recipes lazygit
   # Automatically installs: base → git → lazygit
   ```

2. **Circular Prevention**: The system prevents circular dependencies

3. **Skip Installed**: Already installed recipes are skipped

## Tag Categories

### By Purpose
- **core**: Essential system components (base, ssh, git)
- **development**: Programming tools
- **productivity**: Workflow enhancement
- **security**: Security tools
- **communication**: Team collaboration
- **utility**: General utilities

### By Type
- **cli**: Command-line tools
- **editor**: Text/code editors
- **languages**: Programming languages
- **terminal**: Terminal emulators
- **browser**: Web browsers
- **fonts**: Typography

### By Technology
- **javascript**: JS ecosystem (nvm, deno)
- **git**: Git-related (git, lazygit, gh, gthmb)
- **ai**: AI-enhanced tools (cursor, claude-code)
- **database**: Database tools (firefoo, turso)
- **containers**: Container tech (docker)

## Recommended Installation Profiles

### Minimal Developer
```bash
# Core + essential dev tools
base, ssh, git, nvm, docker, gh, ripgrep, fzf
```

### Full Stack Developer
```bash
# All development tools
base, ssh, git, nvm, rust, golang, docker, 
lazygit, gh, ripgrep, fzf, jaq, bruno, cursor
```

### DevOps Engineer
```bash
# Infrastructure focused
base, ssh, git, docker, golang, ngrok, 
turso, gh, ripgrep, jaq, helix
```

## Best Practices

1. **Always install base first** - It contains essential packages
2. **Check dependencies** - Some tools need others (e.g., lazygit needs git)
3. **Use tags for batch install** - Future feature to install by tag
4. **Review before installing** - Each recipe prompts for confirmation