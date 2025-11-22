# How to Build the Solidity Compiler

This guide explains how to compile the Solidity compiler from source with EIP-8078 support.

## System Requirements

- **OS:** Ubuntu 24.04 LTS (or similar Linux distribution)
- **CMake:** 3.13.0 or higher
- **Boost:** 1.83.0 or higher
- **Compiler:** GCC 13.3.0+ or Clang 18.1.3+
- **Additional:** Git, build-essential

## Quick Start (Recommended)

### Option 1: Using the Build Script (Easiest)

```bash
# Install dependencies first (see below)
# Then run the build script:
./scripts/build.sh

# The compiler will be at: build/solc/solc
```

### Option 2: Manual Build

```bash
# 1. Create build directory
mkdir -p build
cd build

# 2. Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# 3. Compile (using 4 cores)
make -j4

# 4. The compiler is now at: build/solc/solc
```

## Step-by-Step Instructions

### Step 1: Install Dependencies

#### On Ubuntu 24.04 (Current System):

```bash
# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    libboost1.83-all-dev

# Verify installations
cmake --version       # Should be >= 3.13.0
gcc --version         # Should be >= 13.3.0
dpkg -l | grep boost  # Should show 1.83
```

#### If Boost 1.83 is Not Available:

On older systems, you may need to add a PPA or build Boost from source:

```bash
# Option A: Add Ubuntu toolchain PPA (for newer packages)
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install libboost1.83-all-dev

# Option B: Build Boost from source (if package not available)
wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz
tar xzf boost_1_83_0.tar.gz
cd boost_1_83_0
./bootstrap.sh --prefix=/usr/local
sudo ./b2 install
```

### Step 2: Clone Repository (if not already done)

```bash
git clone https://github.com/bitcoinbrisbane/solidity.git
cd solidity
git checkout claude/verify-solidity-eip-alignment-013A1gVMfHnkNGYriiDHGLKf
```

### Step 3: Initialize Submodules

```bash
git submodule update --init --recursive
```

### Step 4: Build the Compiler

#### Using the Build Script (Recommended):

```bash
./scripts/build.sh Release
```

This will:
- Create the `build/` directory
- Run CMake configuration
- Compile with 2 cores
- Optionally install system-wide (requires sudo)

#### Manual Build:

```bash
# Create and enter build directory
mkdir -p build
cd build

# Configure the build
cmake .. -DCMAKE_BUILD_TYPE=Release

# Compile (adjust -j flag based on your CPU cores)
make -j$(nproc)

# Optionally install system-wide
sudo make install
```

### Step 5: Verify the Build

```bash
# Check the compiler version
./build/solc/solc --version

# Should output something like:
# solc, the solidity compiler commandline interface
# Version: 0.8.x+commit.xxxxxxxx.Linux.g++
```

### Step 6: Test EIP-8078 Features

```bash
# Compile one of the example contracts
./build/solc/solc --bin --abi test/eip8078-examples/PriceOracle.sol

# Check that ABI includes subscribable metadata
./build/solc/solc --abi test/eip8078-examples/PriceOracle.sol | grep subscribable
# Should output: "subscribable": true

# Run the automated test suite
cd test/eip8078-examples
BUILD_DIR=../../build ./test_compilation.sh
```

## Build Options

### Debug Build

For development with debugging symbols:

```bash
mkdir -p build-debug
cd build-debug
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j4
```

### Optimization Levels

```bash
# Release (optimized, no debug info)
cmake .. -DCMAKE_BUILD_TYPE=Release

# Debug (with debug symbols, no optimization)
cmake .. -DCMAKE_BUILD_TYPE=Debug

# RelWithDebInfo (optimized with debug info)
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
```

### Additional CMake Options

```bash
# Enable tests
cmake .. -DTESTS=ON

# Disable static linking
cmake .. -DSOLC_STATIC_STDLIBS=OFF

# Use Clang instead of GCC
cmake .. -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang
```

## Troubleshooting

### Error: "Could NOT find Boost"

**Problem:** Boost library not found or version too old (need 1.83.0+)

**Solution:**
```bash
# Check installed version
dpkg -l | grep libboost

# Install correct version
sudo apt-get install libboost1.83-all-dev

# If not available, see Step 1 for building from source
```

### Error: "CMake version too old"

**Problem:** CMake version < 3.13.0

**Solution:**
```bash
# Remove old CMake
sudo apt-get remove cmake

# Install newer version from official website
wget https://cmake.org/files/v3.28/cmake-3.28.0-linux-x86_64.tar.gz
tar xzf cmake-3.28.0-linux-x86_64.tar.gz
sudo mv cmake-3.28.0-linux-x86_64 /opt/cmake
sudo ln -s /opt/cmake/bin/* /usr/local/bin/

# Verify
cmake --version
```

### Error: "make: *** No targets specified"

**Problem:** Not in build directory or CMake not run

**Solution:**
```bash
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```

### Build Fails with "undefined reference" errors

**Problem:** Missing dependencies or linker issues

**Solution:**
```bash
# Clean and rebuild
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make clean
make -j4
```

### Out of Memory During Compilation

**Problem:** Not enough RAM for parallel compilation

**Solution:**
```bash
# Use fewer cores
make -j1  # Single core, slower but uses less memory

# Or
make -j2  # Use only 2 cores
```

## Using the Compiled Compiler

### Basic Usage

```bash
# Compile a contract
./build/solc/solc --bin --abi MyContract.sol

# Output to files
./build/solc/solc -o output/ --bin --abi MyContract.sol

# Generate ABI only
./build/solc/solc --abi MyContract.sol

# Check for subscribable events in ABI
./build/solc/solc --abi PriceOracle.sol | grep -A 5 subscribable
```

### Install System-Wide (Optional)

```bash
cd build
sudo make install

# Now you can use 'solc' directly
solc --version
```

### Use Without Installing

```bash
# Add to PATH temporarily
export PATH=$PATH:/home/user/solidity/build/solc

# Or create an alias
alias solc=/home/user/solidity/build/solc/solc

# Or use absolute path
/home/user/solidity/build/solc/solc --version
```

## Testing EIP-8078 Examples

```bash
# Set the build directory
export BUILD_DIR=/home/user/solidity/build

# Run the test script
cd test/eip8078-examples
./test_compilation.sh

# Expected output:
# [1/6] Compiling PriceOracle.sol...
# ✓ PriceOracle.sol compiled successfully
# [2/6] Compiling DerivedProtocol.sol...
# ✓ DerivedProtocol.sol compiled successfully
# ... etc ...
# All tests passed!
```

## Quick Reference

```bash
# Full build from scratch
git submodule update --init --recursive
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4

# Rebuild after code changes
cd build
make -j4

# Clean build
cd build
make clean
make -j4

# Complete clean (removes all build files)
rm -rf build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```

## Build Time

- **First build:** 10-30 minutes (depending on CPU)
- **Incremental builds:** 1-5 minutes
- **Clean rebuild:** 5-15 minutes

## Resources

- **Official Build Docs:** https://docs.soliditylang.org/en/latest/installing-solidity.html#building-from-source
- **Minimum Requirements Script:** `scripts/ci/install_and_check_minimum_requirements.sh`
- **Build Script:** `scripts/build.sh`
- **EIP-8078 Examples:** `test/eip8078-examples/`

## Next Steps After Building

1. Test basic compilation: `./build/solc/solc --version`
2. Compile EIP-8078 examples: `cd test/eip8078-examples && ../../build/solc/solc PriceOracle.sol`
3. Check ABI output: `./build/solc/solc --abi test/eip8078-examples/PriceOracle.sol`
4. Run test suite: `cd test/eip8078-examples && BUILD_DIR=../../build ./test_compilation.sh`

## EIP-8078 Specific Notes

This branch includes support for:
- ✅ `subscribable` keyword on events
- ✅ `gasHint(value)` annotation
- ✅ Extended ABI with subscribable metadata
- ⏳ Subscribe/unsubscribe statement syntax (AST only, parser pending)

See `test/eip8078-examples/README.md` for detailed examples and `EIP_ALIGNMENT_REPORT.md` for implementation status.
