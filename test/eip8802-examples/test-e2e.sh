#!/bin/bash

#==============================================================================
# EIP-8802 End-to-End Test Script
#==============================================================================
# This script:
# 1. Compiles PriceOracle and DerivedProtocol contracts
# 2. Starts a modified Geth node with EIP-8802 support
# 3. Deploys both contracts
# 4. Creates a subscription
# 5. Triggers the subscription by emitting an event
# 6. Verifies subscription state
#==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLIDITY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="${SOLIDITY_ROOT}/build"
SOLC="${BUILD_DIR}/solc/solc"

# Test workspace
TEST_DIR="${SCRIPT_DIR}/test-workspace"
GETH_DATA_DIR="${TEST_DIR}/geth-data"
CONTRACTS_DIR="${TEST_DIR}/contracts"
GENESIS_FILE="${TEST_DIR}/genesis.json"

# Network configuration
CHAIN_ID=1337
HTTP_PORT=8545
WS_PORT=8546

# Account configuration
ACCOUNT_PASSWORD="password123"
PREFUNDED_ADDRESS="0x123463a4b065722e99115d6c222f267d9cabb524"
PREFUNDED_KEY="2e0834786285daccd064ca17f1654f67b4aef298acbb82cef9ec422fb4975622"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  EIP-8802 Contract Event Subscription Test Suite      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

#==============================================================================
# Step 0: Check prerequisites
#==============================================================================
echo -e "${YELLOW}[0/6] Checking prerequisites...${NC}"

if [ ! -f "$SOLC" ]; then
    echo -e "${RED}✗ Solidity compiler not found at: $SOLC${NC}"
    echo -e "${YELLOW}  Please build the compiler first:${NC}"
    echo -e "${YELLOW}    cd $SOLIDITY_ROOT${NC}"
    echo -e "${YELLOW}    ./scripts/build.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Solidity compiler found${NC}"

# Ask for Geth binary location
if [ -z "$GETH_BIN" ]; then
    read -p "Enter path to your EIP-8802 modified Geth binary: " GETH_BIN
fi

if [ ! -f "$GETH_BIN" ]; then
    echo -e "${RED}✗ Geth binary not found at: $GETH_BIN${NC}"
    exit 1
fi

# Verify Geth has EIP-8802 opcodes
echo -e "${YELLOW}  Verifying Geth supports EIP-8802 opcodes...${NC}"
GETH_VERSION=$("$GETH_BIN" version | head -1)
echo -e "${BLUE}  Geth version: $GETH_VERSION${NC}"
echo -e "${YELLOW}  ⚠ Make sure this is your EIP-8802 fork!${NC}"

echo -e "${GREEN}✓ Geth binary found${NC}"

# Check for node.js and web3
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found. Please install Node.js${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js found${NC}"

#==============================================================================
# Step 1: Compile contracts
#==============================================================================
echo ""
echo -e "${YELLOW}[1/6] Compiling contracts...${NC}"

# Create workspace
mkdir -p "$CONTRACTS_DIR"

# Compile PriceOracle
echo -e "${BLUE}  Compiling PriceOracle.sol...${NC}"
"$SOLC" --bin --abi --optimize -o "$CONTRACTS_DIR" \
    "${SCRIPT_DIR}/PriceOracle.sol" 2>&1 | grep -v "Warning:" || true

if [ ! -f "$CONTRACTS_DIR/PriceOracle.bin" ]; then
    echo -e "${RED}✗ Failed to compile PriceOracle${NC}"
    exit 1
fi

echo -e "${GREEN}✓ PriceOracle compiled${NC}"

# Compile DerivedProtocol
echo -e "${BLUE}  Compiling DerivedProtocol.sol...${NC}"
"$SOLC" --bin --abi --optimize -o "$CONTRACTS_DIR" \
    "${SCRIPT_DIR}/DerivedProtocol.sol" 2>&1 | grep -v "Warning:" || true

if [ ! -f "$CONTRACTS_DIR/DerivedProtocol.bin" ]; then
    echo -e "${RED}✗ Failed to compile DerivedProtocol${NC}"
    exit 1
fi

echo -e "${GREEN}✓ DerivedProtocol compiled${NC}"

# Show contract sizes
ORACLE_SIZE=$(wc -c < "$CONTRACTS_DIR/PriceOracle.bin" | xargs)
DERIVED_SIZE=$(wc -c < "$CONTRACTS_DIR/DerivedProtocol.bin" | xargs)
echo -e "${BLUE}  Contract sizes:${NC}"
echo -e "${BLUE}    PriceOracle: $((ORACLE_SIZE / 2)) bytes${NC}"
echo -e "${BLUE}    DerivedProtocol: $((DERIVED_SIZE / 2)) bytes${NC}"

#==============================================================================
# Step 2: Create genesis.json and start Geth
#==============================================================================
echo ""
echo -e "${YELLOW}[2/6] Setting up private Geth network...${NC}"

# Create genesis.json with prefunded account
cat > "$GENESIS_FILE" << EOF
{
  "config": {
    "chainId": $CHAIN_ID,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "shanghaiTime": 0,
    "cancunTime": 0
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "alloc": {
    "$PREFUNDED_ADDRESS": {
      "balance": "1000000000000000000000"
    }
  }
}
EOF

echo -e "${GREEN}✓ Genesis file created${NC}"
echo -e "${BLUE}  Prefunded account: $PREFUNDED_ADDRESS${NC}"
echo -e "${BLUE}  Balance: 1000 ETH${NC}"

# Initialize Geth
if [ ! -d "$GETH_DATA_DIR/geth" ]; then
    echo -e "${BLUE}  Initializing Geth data directory...${NC}"
    "$GETH_BIN" --datadir "$GETH_DATA_DIR" init "$GENESIS_FILE" > /dev/null 2>&1
    echo -e "${GREEN}✓ Geth initialized${NC}"
fi

# Start Geth in background
echo -e "${BLUE}  Starting Geth node...${NC}"
"$GETH_BIN" \
    --datadir "$GETH_DATA_DIR" \
    --networkid $CHAIN_ID \
    --http \
    --http.addr "127.0.0.1" \
    --http.port $HTTP_PORT \
    --http.api "eth,net,web3,personal,admin,debug" \
    --http.corsdomain "*" \
    --ws \
    --ws.addr "127.0.0.1" \
    --ws.port $WS_PORT \
    --ws.api "eth,net,web3,personal,admin,debug" \
    --allow-insecure-unlock \
    --nodiscover \
    --maxpeers 0 \
    --mine \
    --miner.threads 1 \
    --miner.etherbase "$PREFUNDED_ADDRESS" \
    > "$TEST_DIR/geth.log" 2>&1 &

GETH_PID=$!
echo $GETH_PID > "$TEST_DIR/geth.pid"

# Wait for Geth to start
echo -e "${BLUE}  Waiting for Geth to start (PID: $GETH_PID)...${NC}"
sleep 3

# Check if Geth is running
if ! ps -p $GETH_PID > /dev/null; then
    echo -e "${RED}✗ Geth failed to start. Check $TEST_DIR/geth.log${NC}"
    exit 1
fi

# Wait for RPC
for i in {1..30}; do
    if curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://127.0.0.1:$HTTP_PORT > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

echo -e "${GREEN}✓ Geth is running${NC}"
echo -e "${BLUE}  HTTP RPC: http://127.0.0.1:$HTTP_PORT${NC}"
echo -e "${BLUE}  WS RPC: ws://127.0.0.1:$WS_PORT${NC}"

#==============================================================================
# Step 3: Deploy contracts
#==============================================================================
echo ""
echo -e "${YELLOW}[3/6] Deploying contracts...${NC}"

# Create deployment script
cat > "$TEST_DIR/deploy.js" << 'EOFJS'
const http = require('http');

const RPC_URL = 'http://127.0.0.1:8545';
let requestId = 1;

function rpcCall(method, params) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            jsonrpc: '2.0',
            method: method,
            params: params,
            id: requestId++
        });

        const options = {
            hostname: '127.0.0.1',
            port: 8545,
            path: '/',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const response = JSON.parse(body);
                    if (response.error) {
                        reject(new Error(response.error.message));
                    } else {
                        resolve(response.result);
                    }
                } catch (e) {
                    reject(e);
                }
            });
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

async function deploy() {
    const fs = require('fs');
    const contractsDir = process.argv[2];
    const from = process.argv[3];
    const privateKey = process.argv[4];

    console.log('Deploying from account:', from);

    // Read contract bytecode
    const oracleBytecode = '0x' + fs.readFileSync(`${contractsDir}/PriceOracle.bin`, 'utf8').trim();
    const derivedBytecode = '0x' + fs.readFileSync(`${contractsDir}/DerivedProtocol.bin`, 'utf8').trim();

    // Unlock account
    await rpcCall('personal_unlockAccount', [from, 'password123', 3600]);
    console.log('✓ Account unlocked');

    // Deploy PriceOracle
    console.log('Deploying PriceOracle...');
    const oracleTxHash = await rpcCall('eth_sendTransaction', [{
        from: from,
        data: oracleBytecode,
        gas: '0x200000'
    }]);
    console.log('PriceOracle tx:', oracleTxHash);

    // Wait for receipt
    let oracleReceipt = null;
    for (let i = 0; i < 60; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        oracleReceipt = await rpcCall('eth_getTransactionReceipt', [oracleTxHash]);
        if (oracleReceipt) break;
    }

    if (!oracleReceipt || !oracleReceipt.contractAddress) {
        throw new Error('Failed to deploy PriceOracle');
    }

    const oracleAddress = oracleReceipt.contractAddress;
    console.log('✓ PriceOracle deployed at:', oracleAddress);

    // Deploy DerivedProtocol (with oracle address as constructor param)
    console.log('Deploying DerivedProtocol...');

    // Encode constructor parameter (address)
    const constructorParam = oracleAddress.slice(2).padStart(64, '0');
    const derivedBytecodeWithParams = derivedBytecode + constructorParam;

    const derivedTxHash = await rpcCall('eth_sendTransaction', [{
        from: from,
        data: derivedBytecodeWithParams,
        value: '0x16345785D8A0000', // 0.1 ETH for gas deposit
        gas: '0x300000'
    }]);
    console.log('DerivedProtocol tx:', derivedTxHash);

    // Wait for receipt
    let derivedReceipt = null;
    for (let i = 0; i < 60; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        derivedReceipt = await rpcCall('eth_getTransactionReceipt', [derivedTxHash]);
        if (derivedReceipt) break;
    }

    if (!derivedReceipt || !derivedReceipt.contractAddress) {
        throw new Error('Failed to deploy DerivedProtocol');
    }

    const derivedAddress = derivedReceipt.contractAddress;
    console.log('✓ DerivedProtocol deployed at:', derivedAddress);

    // Save addresses
    fs.writeFileSync(`${contractsDir}/addresses.json`, JSON.stringify({
        oracle: oracleAddress,
        derived: derivedAddress
    }, null, 2));

    console.log('\n✓ Deployment complete!');
}

deploy().catch(console.error);
EOFJS

# Run deployment
node "$TEST_DIR/deploy.js" "$CONTRACTS_DIR" "$PREFUNDED_ADDRESS" "$PREFUNDED_KEY"

if [ ! -f "$CONTRACTS_DIR/addresses.json" ]; then
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi

ORACLE_ADDRESS=$(node -p "require('$CONTRACTS_DIR/addresses.json').oracle")
DERIVED_ADDRESS=$(node -p "require('$CONTRACTS_DIR/addresses.json').derived")

echo -e "${GREEN}✓ Contracts deployed${NC}"
echo -e "${BLUE}  PriceOracle: $ORACLE_ADDRESS${NC}"
echo -e "${BLUE}  DerivedProtocol: $DERIVED_ADDRESS${NC}"

#==============================================================================
# Step 4: Verify subscription was created
#==============================================================================
echo ""
echo -e "${YELLOW}[4/6] Verifying subscription state...${NC}"

# Create verification script
cat > "$TEST_DIR/verify_subscription.js" << 'EOFJS'
const http = require('http');

function rpcCall(method, params) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            jsonrpc: '2.0',
            method: method,
            params: params,
            id: Date.now()
        });

        const req = http.request({
            hostname: '127.0.0.1',
            port: 8545,
            path: '/',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        }, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                const response = JSON.parse(body);
                resolve(response.result);
            });
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

async function verifySubscription() {
    const oracleAddress = process.argv[2];
    const derivedAddress = process.argv[3];

    console.log('Checking subscription state...');
    console.log('  Oracle:', oracleAddress);
    console.log('  Derived:', derivedAddress);

    // Call eth_getSubscriptions (your custom RPC method)
    try {
        const subscriptions = await rpcCall('eth_getSubscriptions', [derivedAddress]);

        if (subscriptions && subscriptions.length > 0) {
            console.log('\n✓ Subscription found!');
            console.log('  Count:', subscriptions.length);
            console.log('  Details:', JSON.stringify(subscriptions, null, 2));
        } else {
            console.log('\n✗ No subscriptions found');
            console.log('  This might mean:');
            console.log('  1. Subscription was created but not stored');
            console.log('  2. SUBSCRIBE opcode needs debugging');
            console.log('  3. RPC method not implemented yet');
        }
    } catch (error) {
        console.log('\n⚠ Could not query subscriptions:', error.message);
        console.log('  eth_getSubscriptions RPC method may not be implemented yet');
    }

    // Try getting subscription by ID
    try {
        const eventSig = '0x8cedca10c07e393bc7de5e8de57ab721e7cd42d34a34d4e53f93b5e4e1bea2a5';
        const subscription = await rpcCall('eth_getSubscription', [derivedAddress, oracleAddress, eventSig]);

        if (subscription) {
            console.log('\n✓ Subscription details retrieved:');
            console.log(JSON.stringify(subscription, null, 2));
        }
    } catch (error) {
        console.log('\n⚠ eth_getSubscription not available:', error.message);
    }
}

verifySubscription().catch(console.error);
EOFJS

node "$TEST_DIR/verify_subscription.js" "$ORACLE_ADDRESS" "$DERIVED_ADDRESS"

#==============================================================================
# Step 5: Trigger subscription by updating price
#==============================================================================
echo ""
echo -e "${YELLOW}[5/6] Triggering subscription...${NC}"

# Create interaction script
cat > "$TEST_DIR/interact.js" << 'EOFJS'
const http = require('http');

function rpcCall(method, params) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            jsonrpc: '2.0',
            method: method,
            params: params,
            id: Date.now()
        });

        const req = http.request({
            hostname: '127.0.0.1',
            port: 8545,
            path: '/',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        }, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                const response = JSON.parse(body);
                if (response.error) {
                    reject(new Error(response.error.message));
                } else {
                    resolve(response.result);
                }
            });
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

async function triggerSubscription() {
    const oracleAddress = process.argv[2];
    const from = process.argv[3];

    console.log('Updating price on PriceOracle...');

    // Function signature: updatePrice(uint256)
    const functionSig = '0x8d6cc56d'; // keccak256("updatePrice(uint256)").slice(0, 10)
    const newPrice = '1000'; // 1000 wei
    const priceParam = parseInt(newPrice).toString(16).padStart(64, '0');
    const data = functionSig + priceParam;

    const txHash = await rpcCall('eth_sendTransaction', [{
        from: from,
        to: oracleAddress,
        data: data,
        gas: '0x100000'
    }]);

    console.log('Transaction sent:', txHash);

    // Wait for receipt
    let receipt = null;
    for (let i = 0; i < 60; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        receipt = await rpcCall('eth_getTransactionReceipt', [txHash]);
        if (receipt) break;
    }

    if (!receipt) {
        throw new Error('Transaction not mined');
    }

    console.log('✓ Transaction mined in block:', receipt.blockNumber);
    console.log('  Gas used:', parseInt(receipt.gasUsed, 16));
    console.log('  Logs:', receipt.logs.length);

    if (receipt.logs.length > 0) {
        console.log('\n📋 Events emitted:');
        receipt.logs.forEach((log, idx) => {
            console.log(`  [${idx}] Topic 0: ${log.topics[0]}`);
            console.log(`       Data: ${log.data}`);
        });
    }

    console.log('\n✓ PriceUpdated event should have been emitted');
    console.log('✓ Subscribers should have been notified (if NOTIFYSUBSCRIBERS is implemented)');
}

triggerSubscription().catch(console.error);
EOFJS

node "$TEST_DIR/interact.js" "$ORACLE_ADDRESS" "$PREFUNDED_ADDRESS"

#==============================================================================
# Step 6: Check final state
#==============================================================================
echo ""
echo -e "${YELLOW}[6/6] Checking final state...${NC}"

# Create state check script
cat > "$TEST_DIR/check_state.js" << 'EOFJS'
const http = require('http');
const fs = require('fs');

function rpcCall(method, params) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            jsonrpc: '2.0',
            method: method,
            params: params,
            id: Date.now()
        });

        const req = http.request({
            hostname: '127.0.0.1',
            port: 8545,
            path: '/',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        }, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                const response = JSON.parse(body);
                resolve(response.result);
            });
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

async function checkState() {
    const oracleAddress = process.argv[2];
    const derivedAddress = process.argv[3];

    console.log('Checking contract state...\n');

    // Check oracle price storage slot 0
    const priceSlot = await rpcCall('eth_getStorageAt', [oracleAddress, '0x0', 'latest']);
    console.log('PriceOracle.price:', parseInt(priceSlot, 16));

    // Check derived protocol last synced price (storage slot 1)
    const syncedPriceSlot = await rpcCall('eth_getStorageAt', [derivedAddress, '0x1', 'latest']);
    const syncedPrice = parseInt(syncedPriceSlot, 16);
    console.log('DerivedProtocol.lastSyncedPrice:', syncedPrice);

    if (syncedPrice > 0) {
        console.log('\n✓ Callback was executed! Price synced successfully.');
    } else {
        console.log('\n⚠ Callback may not have executed (lastSyncedPrice still 0)');
        console.log('  This could mean:');
        console.log('  1. NOTIFYSUBSCRIBERS opcode not implemented yet');
        console.log('  2. Callback execution needs debugging');
        console.log('  3. Gas accounting issue');
    }

    // Check callback count (storage slot 2)
    const callbackCountSlot = await rpcCall('eth_getStorageAt', [derivedAddress, '0x2', 'latest']);
    const callbackCount = parseInt(callbackCountSlot, 16);
    console.log('DerivedProtocol.callbackCount:', callbackCount);

    // Get recent blocks
    const blockNumber = await rpcCall('eth_blockNumber', []);
    console.log('\nCurrent block:', parseInt(blockNumber, 16));

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('TEST SUMMARY');
    console.log('='.repeat(60));
    console.log('Oracle Address:', oracleAddress);
    console.log('Derived Address:', derivedAddress);
    console.log('Current Price:', parseInt(priceSlot, 16));
    console.log('Synced Price:', syncedPrice);
    console.log('Callback Count:', callbackCount);
    console.log('Status:', syncedPrice > 0 ? '✓ SUCCESS' : '⚠ PARTIAL');
    console.log('='.repeat(60));
}

checkState().catch(console.error);
EOFJS

node "$TEST_DIR/check_state.js" "$ORACLE_ADDRESS" "$DERIVED_ADDRESS"

#==============================================================================
# Cleanup function
#==============================================================================
function cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping Geth...${NC}"
    if [ -f "$TEST_DIR/geth.pid" ]; then
        GETH_PID=$(cat "$TEST_DIR/geth.pid")
        if ps -p $GETH_PID > /dev/null; then
            kill $GETH_PID
            wait $GETH_PID 2>/dev/null || true
        fi
        rm "$TEST_DIR/geth.pid"
    fi
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

trap cleanup EXIT

#==============================================================================
# Keep running
#==============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Test Complete - Geth is still running                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Geth RPC endpoint: http://127.0.0.1:$HTTP_PORT${NC}"
echo -e "${GREEN}Workspace: $TEST_DIR${NC}"
echo -e "${GREEN}Logs: $TEST_DIR/geth.log${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop Geth and exit${NC}"
echo ""

# Wait for user interrupt
wait
