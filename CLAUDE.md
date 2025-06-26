# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Core Commands

### Building and Testing

```bash
# Run all tests (as in CI)
./tests/run-all-tests.sh

# Test individual recipes in Docker
./tests/test-recipe.sh golang
./tests/test-recipe.sh discord

# Test encryption/decryption
CI=true ./tests/integration-test.sh

# Test dependencies
python3 tests/check-dependencies.py
./tests/test-dependencies.sh

# Lint/validate YAML
python3 -c "import yaml; yaml.safe_load(open('recipes.yaml'))"
```

### Development Workflow

```bash
# Create test machine for development
./resetup init test-machine
./resetup pack test-machine

# Test recipe installation
./resetup recipes test-machine golang -f

# Test in Docker environment
./resetup docker
```

## Architecture Overview

### Command Flow

The `resetup` script is the main entry point that routes to scripts in
`scripts/`:

- `init` → Creates machine configuration structure
- `pack` → Encrypts machine data to .aes256 file
- `unpack` → Decrypts and installs recipes (calls `dec` then `recipes`)
- `recipes` → Recipe installation engine with dependency resolution

### Machine Configuration Structure

```
machines/[machine]/
├── master.cnf          # Environment variables for recipes
├── cookbook.yaml       # Which recipes to install
├── files/              # SSH keys, dotfiles, configs
└── .installed_recipes  # Track what's installed (not encrypted)
```

### Recipe System

- Recipes are bash scripts in `recipes/` that source `master.cnf` for config
- Dependencies defined in `recipes.yaml` are automatically resolved
- Installation tracking prevents duplicate installs unless `-f` flag used
- Recipes can fail gracefully in Docker/test environments (e.g., snap fallback)

### Encryption Approach

- Uses OpenSSL AES-256 with PBKDF2 for password-based encryption
- Each machine has separate encrypted file (`machines/[machine].aes256`)
- `.installed_recipes` excluded from encryption to track state

## Critical Rules

### Test Data Management

- **All test-generated data MUST live in `tests/` folder, never outside**
- Tests create data in subdirectories like `tests/.integration-test/`
- Never create `machines/` or `data/` directories in project root during tests

### Code Modifications

- Ensure all tests pass before committing
- When replacing code, remove the prior implementation to avoid duplication
- Keep README.md updated with any new features or changes
- Never delete existing machine .aes256 files
- When adding/removing recipes, update related tests

### Recipe Development

- Check if running in Docker with `[ -f /.dockerenv ]` for environment detection
- Provide fallback installation methods (e.g., snap → deb for Discord)
- Use `systemctl is-active --quiet snapd 2>/dev/null` to check service
  availability
- Always source master.cnf with `. $1` to access configuration variables

### Git Commits

- Include all unstaged files/changes when committing
- Follow existing commit message style in the repository
- Add Co-Authored-By for Claude-generated commits

## Common Patterns

### Docker/CI Detection in Recipes

```bash
if [ -f /.dockerenv ] || ! systemctl is-active --quiet snapd 2>/dev/null; then
    # Fallback installation method
else
    # Primary installation method
fi
```

### Recipe Installation Check

```bash
# Force flag bypasses this check
if grep -q "^$RECIPE_NAME$" "$INSTALLED_FILE" 2>/dev/null; then
    echo "Already installed"
    return 0
fi
```

### Test Directory Creation

```bash
# Always create test data within tests/
mkdir -p tests/.my-test/machines/test-machine
# NOT: mkdir -p machines/test-machine
```

# Additional

- when making any changes ensure that all tests pass
- all test generated data should live @tests/ folder. never outside
- always ensure that you understand what this app is about @README.md
- ensure that we dont have duplicate logic for instance when we replaced code
  that we remove the prior one, which is not needed anymore
- keep README.md always updated
- never delete existing machine .aes256 files
- when we add/remove a recipe we need to add/remove related tests
- when asking for commit and push we should include all unstaged files/changes
