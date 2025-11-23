# Solidity Testing Guide - Running Unit Tests

This guide explains how to run Solidity unit tests, especially for the EIP-8802 features.

## Quick Start

```bash
# 1. Build the compiler (if not already done)
./scripts/build.sh

# 2. Run all tests (takes 30+ minutes)
./scripts/tests.sh

# 3. Run specific test suites (much faster)
./scripts/soltest.sh --run_test libsolidity/semanticTests
```

---

## Test Types

### 1. Semantic Tests (Contract Behavior)
- **Location:** `test/libsolidity/semanticTests/`
- **What they test:** Contract compilation and execution
- **EIP-8802 tests:** `test/libsolidity/semanticTests/events/event_subscribable_*.sol`

### 2. Syntax Tests (Parser/Compiler)
- **Location:** `test/libsolidity/syntaxTests/`
- **What they test:** Syntax parsing and type checking

### 3. Command Line Tests
- **Location:** `test/cmdlineTests/`
- **What they test:** Compiler CLI behavior

### 4. Unit Tests (C++ code)
- **Location:** Various `test/lib*/` directories
- **What they test:** Internal compiler components

---

## Running Tests

### Option 1: Run All Tests (Complete Test Suite)

```bash
./scripts/tests.sh
```

**Warning:** This takes 30-60 minutes and tests multiple EVM versions and optimization levels.

### Option 2: Run Specific Test Suites (Recommended)

#### Run only semantic tests:
```bash
build/test/soltest --run_test libsolidity/semanticTests -- --testpath test
```

#### Run only event tests:
```bash
build/test/soltest --run_test libsolidity/semanticTests/events -- --testpath test
```

#### Run only EIP-8802 subscribable event tests:
```bash
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable* -- --testpath test
```

#### Run syntax tests:
```bash
build/test/soltest --run_test libsolidity/syntaxTests -- --testpath test
```

### Option 3: Use Helper Scripts

#### Using soltest.sh wrapper:
```bash
# Run specific test by name
./scripts/soltest.sh --run_test libsolidity/semanticTests/events/event_subscribable_basic

# Run with progress indicator
./scripts/soltest.sh --show-progress --run_test libsolidity/semanticTests/events

# Run multiple test filters
./scripts/soltest.sh -t libsolidity/semanticTests/events/event_subscribable* -t libsolidity/syntaxTests/events
```

---

## Testing EIP-8802 Features

### Test Subscribable Event Compilation

```bash
# Run all EIP-8802 semantic tests
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable -- --testpath test

# Expected output:
# Running 5 test cases...
# event_subscribable_anonymous
# event_subscribable_basic
# event_subscribable_indexed
# event_subscribable_multiple_params
# event_subscribable_with_gashint
# *** No errors detected
```

### Test Example Contracts Compilation

```bash
cd test/eip8802-examples
BUILD_DIR=../../build ./test_compilation.sh

# Expected output:
# [1/6] Compiling PriceOracle.sol...
# ✓ PriceOracle.sol compiled successfully
# ...
# All tests passed!
```

### Manual Test of Individual Contracts

```bash
# Test basic subscribable event
build/solc/solc --abi test/libsolidity/semanticTests/events/event_subscribable_basic.sol

# Test with gasHint
build/solc/solc --abi test/libsolidity/semanticTests/events/event_subscribable_with_gashint.sol

# Verify ABI includes subscribable metadata
build/solc/solc --abi test/eip8802-examples/PriceOracle.sol | grep -A 10 subscribable
```

---

## Understanding Test Output

### Success:
```
Running 5 test cases...
event_subscribable_basic
event_subscribable_with_gashint
event_subscribable_indexed
event_subscribable_anonymous
event_subscribable_multiple_params

*** No errors detected
```

### Failure:
```
Running 5 test cases...
event_subscribable_basic: FAILED
Expected: "subscribable": true
Got: "subscribable": false

*** 1 failure detected in test suite
```

---

## Semantic Test Format

EIP-8802 semantic tests follow this format:

```solidity
contract Test {
    event subscribable ValueChanged(uint256 newValue) gasHint(50000);

    function changeValue(uint256 _value) public {
        emit ValueChanged(_value);
    }
}
// ----
// changeValue(uint256): 42 ->
// ~ emit ValueChanged(uint256): 0x2a
```

**Format explained:**
- Contract code above `// ----`
- Test cases below `// ----`
- Format: `functionName(params): inputValues -> expectedOutput`
- `~ emit` indicates expected event emission

---

## Common Test Commands

### Run tests with progress:
```bash
./scripts/soltest.sh --show-progress
```

### Run tests with debugging:
```bash
./scripts/soltest.sh --debug
```

### Run specific test with custom EVM version:
```bash
build/test/soltest --run_test libsolidity/semanticTests -- --testpath test --evm-version cancun
```

### Run tests without SMT solver:
```bash
./scripts/tests.sh --no-smt
```

### Run only commandline tests:
```bash
test/cmdlineTests.sh
```

---

## Test File Locations

### EIP-8802 Semantic Tests:
```
test/libsolidity/semanticTests/events/
├── event_subscribable_basic.sol
├── event_subscribable_with_gashint.sol
├── event_subscribable_indexed.sol
├── event_subscribable_anonymous.sol
└── event_subscribable_multiple_params.sol
```

### EIP-8802 Example Contracts:
```
test/eip8802-examples/
├── PriceOracle.sol
├── DerivedProtocol.sol
├── SimpleToken.sol
├── TokenWatcher.sol
├── ComprehensiveTest.sol
├── test_compilation.sh
└── README.md
```

---

## Debugging Failed Tests

### 1. Check compiler output:
```bash
build/solc/solc --abi test/libsolidity/semanticTests/events/event_subscribable_basic.sol
```

### 2. Run single test with verbose output:
```bash
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable_basic --show-progress -- --testpath test
```

### 3. Check test expectations:
```bash
cat test/libsolidity/semanticTests/events/event_subscribable_basic.sol
```

### 4. Debug with GDB:
```bash
./scripts/soltest.sh --debug --run_test libsolidity/semanticTests/events/event_subscribable_basic
```

---

## Running Tests in CI/CD

### Minimal test run (for quick validation):
```bash
# Run only semantic tests for events
build/test/soltest --run_test libsolidity/semanticTests/events -- --testpath test --evm-version cancun
```

### Full test run (for release):
```bash
./scripts/tests.sh
```

---

## Test Development

### Adding New Semantic Tests

1. Create test file in appropriate directory:
```bash
vim test/libsolidity/semanticTests/events/my_new_test.sol
```

2. Follow the format:
```solidity
contract MyTest {
    event subscribable MyEvent(uint value);
    function trigger() public { emit MyEvent(42); }
}
// ----
// trigger() ->
// ~ emit MyEvent(uint256): 0x2a
```

3. Run the test:
```bash
build/test/soltest --run_test libsolidity/semanticTests/events/my_new_test -- --testpath test
```

4. If output differs, the test framework will show expected vs actual

---

## Performance

### Test Suite Runtimes (Approximate)

- **All tests:** 30-60 minutes
- **Semantic tests only:** 10-20 minutes
- **Event semantic tests:** 1-2 minutes
- **EIP-8802 tests only:** < 30 seconds
- **Single test:** < 1 second

### Speed Up Tests

```bash
# Run only essential EVM versions
build/test/soltest -- --testpath test --evm-version cancun

# Run without optimization variants
build/test/soltest -- --testpath test --no-optimize

# Run single test category
build/test/soltest --run_test libsolidity/semanticTests/events -- --testpath test
```

---

## Environment Variables

### Important variables:

```bash
# Set build directory (if not default)
export SOLIDITY_BUILD_DIR=/path/to/build

# Disable SMT tests
export SMT_FLAGS="--no-smt"

# Run in CI mode (affects test selection)
export CI=true
```

---

## Troubleshooting

### "soltest not found"
**Problem:** Test executable not built

**Fix:**
```bash
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make soltest -j4
```

### "No tests executed"
**Problem:** Wrong test path or pattern

**Fix:**
```bash
# Check exact test names
ls test/libsolidity/semanticTests/events/event_subscribable*

# Use exact path
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable_basic -- --testpath test
```

### Tests fail with "subscribable not found"
**Problem:** Feature not fully compiled

**Fix:**
```bash
# Clean rebuild
rm -rf build
./scripts/build.sh
```

### Memory issues during testing
**Fix:**
```bash
# Run tests sequentially
build/test/soltest --run_test libsolidity/semanticTests/events -- --testpath test
# Instead of running all tests with ./scripts/tests.sh
```

---

## Quick Reference

```bash
# Run all tests
./scripts/tests.sh

# Run semantic tests only
build/test/soltest --run_test libsolidity/semanticTests -- --testpath test

# Run EIP-8802 tests only
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable -- --testpath test

# Run example contract tests
cd test/eip8802-examples && BUILD_DIR=../../build ./test_compilation.sh

# Run with progress
./scripts/soltest.sh --show-progress --run_test libsolidity/semanticTests/events

# Run single test
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable_basic -- --testpath test
```

---

## Continuous Integration

For CI pipelines, recommended sequence:

```bash
# 1. Build compiler
./scripts/build.sh

# 2. Run quick smoke tests (EIP-8802 specific)
build/test/soltest --run_test libsolidity/semanticTests/events/event_subscribable -- --testpath test

# 3. Run example compilation tests
cd test/eip8802-examples && BUILD_DIR=../../build ./test_compilation.sh && cd ../..

# 4. Optional: Run full test suite
# ./scripts/tests.sh --no-smt
```

---

## Additional Resources

- **Test Documentation:** `test/README.md` (if exists)
- **Semantic Test Examples:** `test/libsolidity/semanticTests/`
- **Test Scripts:** `scripts/tests.sh`, `scripts/soltest.sh`
- **Build Guide:** `BUILD_GUIDE.md`
- **EIP-8802 Examples:** `test/eip8802-examples/README.md`
