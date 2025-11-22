# Building Solidity on macOS (Intel & Apple Silicon M1/M2/M3)

This guide covers building the Solidity compiler on macOS, including Apple Silicon (M1/M2/M3) Macs.

## Quick Start

```bash
# 1. Install dependencies via Homebrew
brew update
brew install cmake boost

# 2. Configure build (M1/M2/M3 - Apple Silicon)
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/opt/homebrew

# OR for Intel Macs:
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/usr/local

# 3. Build
make -j$(sysctl -n hw.ncpu)

# 4. Test
./solc/solc --version
```

---

## Step-by-Step Instructions

### Step 1: Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**For Apple Silicon (M1/M2/M3)**, Homebrew installs to `/opt/homebrew`
**For Intel Macs**, Homebrew installs to `/usr/local`

### Step 2: Install Dependencies

```bash
# Update Homebrew
brew update

# Install required packages
brew install cmake boost git

# Verify installations
cmake --version    # Should be >= 3.13.0
brew info boost    # Should be >= 1.83.0
```

### Step 3: Check Your Boost Version

```bash
brew info boost
```

**If Boost version is < 1.83.0**, you may need to upgrade:

```bash
# Upgrade Homebrew packages
brew upgrade boost

# Or install specific version (if available)
brew install boost@1.83
```

**Note:** macOS Homebrew often has newer Boost versions (1.84+), which should work fine.

### Step 4: Clone and Prepare Repository

```bash
# Clone repository (if not already done)
git clone https://github.com/bitcoinbrisbane/solidity.git
cd solidity

# Checkout the EIP-8078 branch
git checkout claude/verify-solidity-eip-alignment-013A1gVMfHnkNGYriiDHGLKf

# Initialize submodules
git submodule update --init --recursive
```

### Step 5: Configure Build

#### For Apple Silicon (M1/M2/M3):

```bash
mkdir build
cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/opt/homebrew \
  -DBOOST_ROOT=/opt/homebrew
```

#### For Intel Macs:

```bash
mkdir build
cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/usr/local \
  -DBOOST_ROOT=/usr/local
```

#### Alternative: Let CMake auto-detect Boost location

```bash
mkdir build
cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DBoost_DIR=$(brew --prefix boost)/lib/cmake/Boost-$(brew list --versions boost | awk '{print $2}' | cut -d. -f1-2)
```

### Step 6: Build the Compiler

```bash
# Build with all CPU cores
make -j$(sysctl -n hw.ncpu)

# Or specify number of cores manually
make -j8
```

**Build time:** 15-30 minutes on M1/M2/M3, longer on Intel Macs

### Step 7: Verify Build

```bash
# Check compiler version
./solc/solc --version

# Test EIP-8078 features
./solc/solc --abi ../test/eip8078-examples/PriceOracle.sol | grep subscribable
```

Expected output:
```json
"subscribable": true
```

---

## Troubleshooting

### Error: "Could NOT find Boost"

**Problem:** CMake can't find Boost installation

**Solution 1 - Set CMAKE_PREFIX_PATH:**

```bash
# For Apple Silicon
cmake .. -DCMAKE_PREFIX_PATH=/opt/homebrew

# For Intel
cmake .. -DCMAKE_PREFIX_PATH=/usr/local
```

**Solution 2 - Explicitly set Boost location:**

```bash
# Find Boost installation
brew --prefix boost

# Use that path in CMake
cmake .. -DBOOST_ROOT=$(brew --prefix boost)
```

**Solution 3 - Set environment variable:**

```bash
export BOOST_ROOT=$(brew --prefix boost)
cmake .. -DCMAKE_BUILD_TYPE=Release
```

**Solution 4 - Install Boost if not present:**

```bash
brew install boost
```

### Error: Boost version too old

**Problem:** Installed Boost < 1.83.0

**Solution:**

```bash
# Upgrade Boost
brew upgrade boost

# Verify version
brew info boost

# If still old, try upgrading Homebrew itself
brew update
brew upgrade
```

### Error: "xcrun: error: invalid active developer path"

**Problem:** Xcode Command Line Tools not installed

**Solution:**

```bash
xcode-select --install
```

### Error: "No CMAKE_CXX_COMPILER could be found"

**Problem:** C++ compiler not available

**Solution:**

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Or install full Xcode from App Store
# Then run:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Error: Build fails with "ld: library not found"

**Problem:** Linker can't find libraries

**Solution:**

```bash
# Set library path for Apple Silicon
export LIBRARY_PATH=/opt/homebrew/lib

# Or for Intel
export LIBRARY_PATH=/usr/local/lib

# Then rebuild
cd build
cmake .. -DCMAKE_PREFIX_PATH=/opt/homebrew
make clean
make -j$(sysctl -n hw.ncpu)
```

### Error: "architecture arm64" or "architecture x86_64" mismatch

**Problem:** Mixed architecture binaries (M1 running x86 binaries via Rosetta)

**Solution:**

```bash
# Verify you're using native ARM Homebrew (M1/M2/M3)
which brew
# Should be: /opt/homebrew/bin/brew

# If it shows /usr/local/bin/brew, you have Intel Homebrew
# Reinstall Homebrew for Apple Silicon or specify architecture

# Clean build
rm -rf build
mkdir build && cd build

# Force native build
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/opt/homebrew \
  -DCMAKE_OSX_ARCHITECTURES=arm64
```

---

## M1/M2/M3 Specific Notes

### Homebrew Location

On Apple Silicon, Homebrew uses a different path:
- **Apple Silicon:** `/opt/homebrew`
- **Intel:** `/usr/local`

### Check Your Architecture

```bash
uname -m
# arm64 = Apple Silicon (M1/M2/M3)
# x86_64 = Intel
```

### Using Rosetta (Not Recommended)

If you accidentally have Intel Homebrew on M1:

```bash
# Check Homebrew architecture
file $(which brew)

# If it says "x86_64", you're using Rosetta
# Better to reinstall native ARM Homebrew
```

---

## Complete Build Script for macOS

Save this as `build_macos.sh`:

```bash
#!/bin/bash
set -e

echo "Building Solidity on macOS..."

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo "Detected Apple Silicon (M1/M2/M3)"
    PREFIX_PATH=/opt/homebrew
elif [ "$ARCH" = "x86_64" ]; then
    echo "Detected Intel Mac"
    PREFIX_PATH=/usr/local
else
    echo "Unknown architecture: $ARCH"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install dependencies
echo "Installing dependencies..."
brew install cmake boost

# Get Boost location
BOOST_ROOT=$(brew --prefix boost)
echo "Boost found at: $BOOST_ROOT"

# Initialize submodules
echo "Initializing submodules..."
git submodule update --init --recursive

# Configure build
echo "Configuring build..."
mkdir -p build
cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX_PATH \
  -DBOOST_ROOT=$BOOST_ROOT

# Build
echo "Building (using $(sysctl -n hw.ncpu) cores)..."
make -j$(sysctl -n hw.ncpu)

# Test
echo "Testing build..."
./solc/solc --version

echo ""
echo "✓ Build successful!"
echo "Compiler location: $(pwd)/solc/solc"
```

Make it executable and run:

```bash
chmod +x build_macos.sh
./build_macos.sh
```

---

## Environment Variables Reference

### For Apple Silicon (M1/M2/M3):

```bash
export CMAKE_PREFIX_PATH=/opt/homebrew
export BOOST_ROOT=/opt/homebrew
export LIBRARY_PATH=/opt/homebrew/lib
export CPATH=/opt/homebrew/include
```

### For Intel Macs:

```bash
export CMAKE_PREFIX_PATH=/usr/local
export BOOST_ROOT=/usr/local
export LIBRARY_PATH=/usr/local/lib
export CPATH=/usr/local/include
```

---

## Quick Reference

### Install dependencies:
```bash
brew install cmake boost
```

### Configure for M1/M2/M3:
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/opt/homebrew
```

### Configure for Intel:
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local
```

### Build:
```bash
make -j$(sysctl -n hw.ncpu)
```

### Test EIP-8078:
```bash
./solc/solc --abi ../test/eip8078-examples/PriceOracle.sol | grep subscribable
```

---

## Performance Notes

### Build Times (M1 Max, 10 cores):
- First build: ~10-15 minutes
- Incremental: ~2-3 minutes
- Clean rebuild: ~8-12 minutes

### Build Times (Intel i7, 4 cores):
- First build: ~25-35 minutes
- Incremental: ~5-8 minutes
- Clean rebuild: ~20-30 minutes

---

## Alternative: Using Docker

If you have issues with native building, use Docker:

```bash
# Install Docker Desktop for Mac
# Then build in container
docker run -v $(pwd):/src -w /src ubuntu:24.04 bash -c "
  apt-get update &&
  apt-get install -y build-essential cmake libboost1.83-all-dev git &&
  git submodule update --init --recursive &&
  mkdir -p build && cd build &&
  cmake .. -DCMAKE_BUILD_TYPE=Release &&
  make -j$(nproc)
"
```

---

## Additional Resources

- **Homebrew:** https://brew.sh
- **CMake:** https://cmake.org
- **Boost:** https://www.boost.org
- **Solidity Docs:** https://docs.soliditylang.org/en/latest/installing-solidity.html

---

## Next Steps After Building

1. ✅ Verify build: `./solc/solc --version`
2. ✅ Test EIP-8078: See `TESTING_GUIDE.md`
3. ✅ Run examples: See `test/eip8078-examples/README.md`
4. 📖 Read alignment report: `test/eip8078-examples/EIP_ALIGNMENT_REPORT.md`
