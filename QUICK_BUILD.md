# Quick Build Guide for Solidity with EIP-8078 Support

## TL;DR - Three Commands to Build

```bash
# 1. Install Boost 1.83 (one-time setup)
sudo apt-get update && sudo apt-get install -y libboost1.83-all-dev

# 2. Run the build script
./scripts/build.sh

# 3. Test it works
./build/solc/solc --version
```

That's it! The compiler will be at `build/solc/solc`

---

## Step-by-Step Instructions

### Step 1: Install Boost (Required)

```bash
sudo apt-get update
sudo apt-get install -y libboost1.83-all-dev
```

**Verify:**
```bash
dpkg -l | grep libboost1.83
```

### Step 2: Build the Compiler

**Option A - Using Build Script (Easiest):**
```bash
./scripts/build.sh
```

**Option B - Manual Build:**
```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```

### Step 3: Test the Build

```bash
# Check version
./build/solc/solc --version

# Compile an EIP-8078 example
./build/solc/solc --abi test/eip8078-examples/PriceOracle.sol

# Verify subscribable metadata in ABI
./build/solc/solc --abi test/eip8078-examples/PriceOracle.sol | grep subscribable
```

Expected output from last command:
```json
"subscribable": true
```

## Common Issues

### "Could NOT find Boost"

**Fix:**
```bash
sudo apt-get install libboost1.83-all-dev
```

### Build fails with memory error

**Fix:** Use fewer cores:
```bash
make -j2  # Instead of -j4
```

### "submodule not initialized"

**Fix:**
```bash
git submodule update --init --recursive
```

## What You Get

After building, you'll have:

- **Compiler:** `build/solc/solc`
- **Libraries:** `build/libsolidity/`, `build/liblangutil/`, etc.

## Using the Compiler

### Basic usage:

```bash
# Compile a contract
./build/solc/solc MyContract.sol

# Generate ABI
./build/solc/solc --abi MyContract.sol

# Generate both binary and ABI
./build/solc/solc --bin --abi MyContract.sol
```

### Test EIP-8078 features:

```bash
cd test/eip8078-examples

# Set build directory
export BUILD_DIR=../../build

# Run test script
./test_compilation.sh
```

## Install System-Wide (Optional)

```bash
cd build
sudo make install

# Now 'solc' is available globally
solc --version
```

## Rebuild After Changes

If you modify the code:

```bash
cd build
make -j4
```

Clean rebuild:

```bash
rm -rf build
./scripts/build.sh
```

## Build Time

- **First build:** 15-30 minutes
- **Incremental:** 2-5 minutes
- **Your system:** Ubuntu 24.04 with GCC 13.3.0 (all dependencies met ✅)

## Next Steps

1. ✅ Build the compiler
2. ✅ Test with EIP-8078 examples
3. 📖 Read `test/eip8078-examples/README.md`
4. 📊 Check `test/eip8078-examples/EIP_ALIGNMENT_REPORT.md`

## Need Help?

- Full guide: `BUILD_GUIDE.md`
- Example contracts: `test/eip8078-examples/`
- Alignment report: `test/eip8078-examples/EIP_ALIGNMENT_REPORT.md`
