# Resetup Tests

This directory contains all tests for the resetup project.

## Test Structure

- `test-recipe.sh` - Tests individual recipes in Docker containers
- `check-dependencies.py` - Validates recipe dependencies (no circular deps)
- `test-dependencies.sh` - Tests dependency resolution logic
- `integration-test.sh` - Full integration test of pack/unpack process
- `run-all-tests.sh` - Runs all tests locally

## Running Tests

### Run All Tests
```bash
./tests/run-all-tests.sh
```

### Test Individual Recipe
```bash
./tests/test-recipe.sh ripgrep
./tests/test-recipe.sh golang
```

### Check Dependencies
```bash
python3 tests/check-dependencies.py
./tests/test-dependencies.sh
```

### Integration Test
```bash
./tests/integration-test.sh
```

## GitHub Actions

Tests are automatically run on:
- Every push to `main` or `develop` branches
- Every pull request to `main`

The workflow tests:
1. YAML validation
2. Recipe file existence
3. Circular dependencies
4. Individual recipe installation (matrix)
5. Encryption/decryption
6. Full integration

## Testing Without Real Data

The tests use default configuration files (`.default` extensions) to avoid requiring actual user credentials. The test data structure:

```
data/
├── config/
│   └── master.cnf.default  # Template configuration
└── files/
    ├── .ssh/
    │   └── config.default  # SSH config template
    └── header.bash.default # Bash customization template
```

During tests, these `.default` files are copied without the extension to create a test environment.

## Docker Testing

Each recipe is tested in an isolated Ubuntu 22.04 container to ensure:
- Clean environment installation
- Dependency satisfaction
- Successful execution
- Binary availability after installation

## Adding New Tests

1. Add recipe name to the matrix in `.github/workflows/test.yml`
2. Add verification logic to `test-recipe.sh` if needed
3. Update `run-all-tests.sh` if adding new test categories