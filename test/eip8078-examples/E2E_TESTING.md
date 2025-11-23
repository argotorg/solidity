# EIP-8078 End-to-End Testing Guide

This guide explains how to test the complete EIP-8078 implementation from contract compilation through subscription execution.

## Prerequisites

### 1. Solidity Compiler (Built)
```bash
cd /path/to/solidity
./scripts/build.sh
```

### 2. Modified Geth with EIP-8078 Support
Your Geth fork must implement these opcodes:
- `SUBSCRIBE` (0x5c)
- `UNSUBSCRIBE` (0x5d)
- `NOTIFYSUBSCRIBERS` (0x5e) - optional but recommended

### 3. Node.js
```bash
node --version  # Should be v14+
```

## Quick Start

### 1. Run the automated test:
```bash
cd test/eip8078-examples
./test-e2e.sh
```

### 2. When prompted, enter the path to your Geth binary:
```
Enter path to your EIP-8078 modified Geth binary: /path/to/geth
```

### 3. The script will automatically:
- ✅ Compile PriceOracle and DerivedProtocol
- ✅ Start a private Geth network
- ✅ Deploy both contracts
- ✅ Create a subscription (in DerivedProtocol constructor)
- ✅ Trigger the subscription by updating the price
- ✅ Verify the subscription state

## What the Test Does

### Step 1: Compilation
Compiles both contracts with optimization:
```
PriceOracle.sol → PriceOracle.bin + PriceOracle.abi
DerivedProtocol.sol → DerivedProtocol.bin + DerivedProtocol.abi
```

### Step 2: Network Setup
- Creates a genesis.json with prefunded account
- Starts Geth on port 8545 (HTTP RPC)
- Enables mining for instant block production
- Prefunded account: `0x123463a4b065722e99115d6c222f267d9cabb524`
- Initial balance: 1000 ETH

### Step 3: Contract Deployment

#### Deploy PriceOracle:
```javascript
// No constructor parameters
PriceOracle deployed at: 0x...
```

#### Deploy DerivedProtocol:
```javascript
// Constructor parameters: (oracleAddress)
// Constructor calls subscribe:
constructor(address _oracle) payable {
    oracle = PriceOracle(_oracle);

    // This executes SUBSCRIBE opcode (0x5c)
    subscribe oracle.PriceUpdated(newPrice)
        with onPriceUpdate(newPrice)
        gasLimit 100000
        gasPrice 20 gwei;
}

DerivedProtocol deployed at: 0x...
```

### Step 4: Subscription Verification

Checks subscription state using custom RPC:
```javascript
eth_getSubscriptions(subscriberAddress)
// Returns array of subscriptions

eth_getSubscription(subscriber, target, eventSig)
// Returns specific subscription details
```

### Step 5: Trigger Subscription

Calls `updatePrice(1000)` on PriceOracle:
```javascript
// This should:
// 1. Update oracle.price = 1000
// 2. Emit PriceUpdated(1000) event
// 3. Execute NOTIFYSUBSCRIBERS opcode
// 4. Call DerivedProtocol.onPriceUpdate(1000)
// 5. Update derived.lastSyncedPrice = 1000
```

### Step 6: State Verification

Checks contract storage:
```javascript
PriceOracle.price           → Should be 1000
DerivedProtocol.lastSyncedPrice → Should be 1000 (if callback executed)
DerivedProtocol.callbackCount   → Should be 1 (if callback executed)
```

## Expected Output

### Success Case (Full Implementation):
```
[1/6] Compiling contracts...
✓ PriceOracle compiled
✓ DerivedProtocol compiled

[2/6] Setting up private Geth network...
✓ Geth is running

[3/6] Deploying contracts...
✓ PriceOracle deployed at: 0xabcd...
✓ DerivedProtocol deployed at: 0xef12...

[4/6] Verifying subscription state...
✓ Subscription found!
  Count: 1
  Details: {
    targetAddress: "0xabcd...",
    eventSig: "0x8ced...",
    callbackSelector: "0x1234...",
    gasLimit: 100000,
    gasPrice: 20000000000
  }

[5/6] Triggering subscription...
✓ Transaction mined
✓ PriceUpdated event emitted
✓ Subscribers notified

[6/6] Checking final state...
PriceOracle.price: 1000
DerivedProtocol.lastSyncedPrice: 1000
DerivedProtocol.callbackCount: 1

Status: ✓ SUCCESS
```

### Partial Success (NOTIFYSUBSCRIBERS Not Implemented):
```
[6/6] Checking final state...
PriceOracle.price: 1000
DerivedProtocol.lastSyncedPrice: 0  ← Callback didn't execute
DerivedProtocol.callbackCount: 0

⚠ Callback may not have executed
  This could mean:
  1. NOTIFYSUBSCRIBERS opcode not implemented yet
  2. Callback execution needs debugging
  3. Gas accounting issue

Status: ⚠ PARTIAL
```

## Manual Testing

If you want to run steps manually:

### 1. Compile:
```bash
../../build/solc/solc --bin --abi --optimize PriceOracle.sol
../../build/solc/solc --bin --abi --optimize DerivedProtocol.sol
```

### 2. Start Geth:
```bash
geth --datadir ./geth-data \
     --networkid 1337 \
     --http --http.port 8545 \
     --http.api "eth,net,web3,personal" \
     --mine --miner.threads 1
```

### 3. Deploy with cast (from Foundry):
```bash
# Deploy PriceOracle
cast send --create $(cat PriceOracle.bin) \
    --rpc-url http://localhost:8545 \
    --private-key 0x...

# Deploy DerivedProtocol
cast send --create $(cat DerivedProtocol.bin)<oracleAddress> \
    --value 0.1ether \
    --rpc-url http://localhost:8545 \
    --private-key 0x...
```

### 4. Call updatePrice:
```bash
# Function signature: updatePrice(uint256)
cast send <oracleAddress> \
    "updatePrice(uint256)" 1000 \
    --rpc-url http://localhost:8545 \
    --private-key 0x...
```

### 5. Check state:
```bash
# Read price from PriceOracle (slot 0)
cast storage <oracleAddress> 0 --rpc-url http://localhost:8545

# Read lastSyncedPrice from DerivedProtocol (slot 1)
cast storage <derivedAddress> 1 --rpc-url http://localhost:8545
```

## Debugging

### Check Geth logs:
```bash
tail -f test-workspace/geth.log
```

### Enable debug logging in Geth:
```bash
geth ... --verbosity 5
```

### Check subscription state in Geth:
```javascript
// In Geth console
debug.traceTransaction("<subscriptionTxHash>")
```

### Inspect bytecode:
```bash
../../build/solc/solc --ir --optimize DerivedProtocol.sol | grep verbatim
```

Should show:
```yul
verbatim_6i_1o(hex"5c", ...)  // SUBSCRIBE
```

### Check for opcode in deployed bytecode:
```bash
cast code <derivedAddress> --rpc-url http://localhost:8545 | grep 5c
```

## Troubleshooting

### "Geth failed to start"
- Check if port 8545 is already in use: `lsof -i :8545`
- Check Geth logs: `cat test-workspace/geth.log`
- Verify Geth binary is correct version

### "Failed to compile"
- Ensure Solidity compiler is built: `ls build/solc/solc`
- Check for syntax errors in contracts
- Verify all dependencies are in place

### "Deployment failed"
- Check if account is unlocked
- Verify sufficient gas
- Check Geth is mining: `eth.mining` should be `true`

### "No subscriptions found"
- Verify SUBSCRIBE opcode executed: check transaction receipt
- Check Geth subscription storage implementation
- Verify eth_getSubscriptions RPC is implemented

### "Callback not executed"
- Ensure NOTIFYSUBSCRIBERS is implemented in Geth
- Check gas deposit is sufficient
- Verify callback function selector is correct
- Check Geth logs for callback errors

## RPC Methods Your Geth Should Implement

### eth_getSubscriptions
```javascript
// Request
{
  "jsonrpc": "2.0",
  "method": "eth_getSubscriptions",
  "params": ["0x...subscriberAddress"],
  "id": 1
}

// Response
{
  "jsonrpc": "2.0",
  "result": [
    {
      "id": "0x...",
      "targetAddress": "0x...",
      "eventSignature": "0x...",
      "callbackSelector": "0x...",
      "gasLimit": 100000,
      "gasPrice": 20000000000,
      "depositBalance": "100000000000000000"
    }
  ],
  "id": 1
}
```

### eth_getSubscription
```javascript
// Request
{
  "jsonrpc": "2.0",
  "method": "eth_getSubscription",
  "params": ["0x...subscriptionId"],
  "id": 1
}

// Response
{
  "jsonrpc": "2.0",
  "result": {
    "id": "0x...",
    "targetAddress": "0x...",
    "subscriberAddress": "0x...",
    "eventSignature": "0x...",
    "callbackAddress": "0x...",
    "callbackSelector": "0x...",
    "gasLimit": 100000,
    "gasPrice": 20000000000,
    "depositBalance": "100000000000000000",
    "active": true
  },
  "id": 1
}
```

### eth_getCallbackHistory
```javascript
// Request
{
  "jsonrpc": "2.0",
  "method": "eth_getCallbackHistory",
  "params": ["0x...subscriptionId", "0x0", "latest"],
  "id": 1
}

// Response
{
  "jsonrpc": "2.0",
  "result": [
    {
      "blockNumber": "0x10",
      "transactionHash": "0x...",
      "success": true,
      "gasUsed": 50000,
      "returnData": "0x..."
    }
  ],
  "id": 1
}
```

## Test Workspace Structure

After running the test, you'll have:
```
test-workspace/
├── genesis.json          # Network configuration
├── geth-data/           # Blockchain data
├── geth.log             # Geth output
├── geth.pid             # Process ID
├── contracts/
│   ├── PriceOracle.bin
│   ├── PriceOracle.abi
│   ├── DerivedProtocol.bin
│   ├── DerivedProtocol.abi
│   └── addresses.json   # Deployed addresses
├── deploy.js            # Deployment script
├── verify_subscription.js
├── interact.js          # Interaction script
└── check_state.js       # State verification
```

## Cleanup

The script automatically cleans up on exit (Ctrl+C).

Manual cleanup:
```bash
rm -rf test-workspace/
```

## Next Steps

After successful testing:

1. **Verify opcode execution:** Check Geth logs for SUBSCRIBE/UNSUBSCRIBE execution
2. **Test unsubscribe:** Call `derived.cleanup()` and verify subscription removed
3. **Test multiple subscribers:** Deploy multiple DerivedProtocol instances
4. **Test gas depletion:** Deplete gas deposit and verify graceful handling
5. **Benchmark performance:** Measure gas costs and execution time

## Integration with CI/CD

To run in CI:
```bash
# Set environment variables
export GETH_BIN=/path/to/geth
export SOLIDITY_BUILD_DIR=/path/to/build

# Run test
./test-e2e.sh

# Check exit code
if [ $? -eq 0 ]; then
    echo "✓ E2E test passed"
else
    echo "✗ E2E test failed"
    exit 1
fi
```

## Support

For issues:
1. Check `test-workspace/geth.log`
2. Enable verbose logging: `--verbosity 5`
3. Verify opcodes are implemented in Geth
4. Check contract storage with `cast storage`
5. Review transaction receipts for errors
