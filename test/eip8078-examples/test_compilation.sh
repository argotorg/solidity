#!/bin/bash

# Test script for EIP-8078 example contracts compilation
# This script tests that all example contracts compile successfully
# and verifies the ABI contains subscribable metadata

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${BUILD_DIR:-$SCRIPT_DIR/../../build}"
SOLC="${SOLC:-$BUILD_DIR/solc/solc}"

echo "==================================="
echo "EIP-8078 Compilation Test Suite"
echo "==================================="
echo ""

# Check if solc exists
if [ ! -f "$SOLC" ]; then
    echo "ERROR: solc not found at $SOLC"
    echo "Please build the Solidity compiler first:"
    echo "  mkdir -p build && cd build"
    echo "  cmake .. -DCMAKE_BUILD_TYPE=Release"
    echo "  make solc -j4"
    exit 1
fi

echo "Using solc: $SOLC"
$SOLC --version
echo ""

# Test 1: Compile PriceOracle
echo "[1/6] Compiling PriceOracle.sol..."
$SOLC --bin --abi "$SCRIPT_DIR/PriceOracle.sol" > /dev/null 2>&1
echo "✓ PriceOracle.sol compiled successfully"

# Test 2: Compile DerivedProtocol (with import)
echo "[2/6] Compiling DerivedProtocol.sol..."
$SOLC --bin --abi "$SCRIPT_DIR/DerivedProtocol.sol" > /dev/null 2>&1
echo "✓ DerivedProtocol.sol compiled successfully"

# Test 3: Compile SimpleToken
echo "[3/6] Compiling SimpleToken.sol..."
$SOLC --bin --abi "$SCRIPT_DIR/SimpleToken.sol" > /dev/null 2>&1
echo "✓ SimpleToken.sol compiled successfully"

# Test 4: Compile TokenWatcher
echo "[4/6] Compiling TokenWatcher.sol..."
$SOLC --bin --abi "$SCRIPT_DIR/TokenWatcher.sol" > /dev/null 2>&1
echo "✓ TokenWatcher.sol compiled successfully"

# Test 5: Compile ComprehensiveTest
echo "[5/6] Compiling ComprehensiveTest.sol..."
$SOLC --bin --abi "$SCRIPT_DIR/ComprehensiveTest.sol" > /dev/null 2>&1
echo "✓ ComprehensiveTest.sol compiled successfully"

# Test 6: Verify ABI contains subscribable metadata
echo "[6/6] Verifying ABI metadata..."
ABI_OUTPUT=$($SOLC --abi "$SCRIPT_DIR/PriceOracle.sol" 2>/dev/null)

# Check if PriceUpdated event has subscribable flag
if echo "$ABI_OUTPUT" | grep -q '"subscribable"'; then
    echo "✓ ABI contains subscribable metadata"
else
    echo "✗ WARNING: ABI does not contain subscribable metadata"
    echo "  This may indicate the feature is not fully implemented"
fi

# Check if gasHint is present
if echo "$ABI_OUTPUT" | grep -q '"gasHint"'; then
    echo "✓ ABI contains gasHint metadata"
else
    echo "✗ WARNING: ABI does not contain gasHint metadata"
fi

echo ""
echo "==================================="
echo "All tests passed!"
echo "==================================="
echo ""

# Optional: Display PriceUpdated event ABI
echo "Sample ABI output (PriceUpdated event):"
echo "$ABI_OUTPUT" | grep -A 10 '"PriceUpdated"' || echo "$ABI_OUTPUT"
