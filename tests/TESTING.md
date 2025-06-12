# Testing Strategy for Resetup

## Overview

The resetup project now has comprehensive testing to ensure reliability and prevent regressions.

## Test Coverage

### 1. **Unit Tests**
- Individual recipe installation in Docker
- Dependency resolution logic
- YAML configuration validation

### 2. **Integration Tests**
- Full pack/unpack cycle
- Recipe system end-to-end
- Encryption/decryption verification

### 3. **Static Analysis**
- Circular dependency detection
- Recipe file existence checks
- Shell script linting (optional)

## GitHub Actions Workflow

The `.github/workflows/test.yml` runs on:
- Push to main/develop
- Pull requests to main

### Workflow Jobs:

1. **validate-yaml**
   - Ensures recipes.yaml is valid
   - Verifies all recipe files exist

2. **test-recipes** (Matrix)
   - Tests each recipe in isolated Docker container
   - Parallel execution for speed
   - Fail-fast disabled to see all failures

3. **test-encryption**
   - Tests pack/unpack without user password
   - Uses test data with .default files

4. **test-dependencies**
   - Checks for circular dependencies
   - Validates dependency graph

5. **integration-test**
   - Full system test
   - Creates test environment
   - Runs sample installation

## Local Testing

```bash
# Run all tests
./tests/run-all-tests.sh

# Test specific recipe
./tests/test-recipe.sh golang

# Check dependencies
python3 tests/check-dependencies.py

# Run integration test
./tests/integration-test.sh
```

## Test Data Structure

```
data/
├── config/
│   ├── master.cnf         # Real config (gitignored)
│   └── master.cnf.default # Template for testing
└── files/
    ├── .ssh/
    │   ├── config         # Real SSH config (gitignored)
    │   └── config.default # Template for testing
    └── header.bash.default # Bash customization template
```

## Security

- No real passwords or keys in tests
- Default files use placeholder values
- Test encryption uses hardcoded test password
- All sensitive data is gitignored

## Adding New Recipes

When adding a new recipe:

1. Add to `recipes.yaml`
2. Create recipe script in `recipes/`
3. Add to test matrix in `.github/workflows/test.yml`
4. Add verification logic to `test-recipe.sh` if needed
5. Run `./tests/run-all-tests.sh` locally

## Docker Test Environment

Each recipe is tested in:
- Ubuntu 22.04 base image
- Minimal dependencies installed
- Non-root user with sudo
- Isolated from host system

This ensures recipes work in clean environments and don't depend on pre-existing tools.