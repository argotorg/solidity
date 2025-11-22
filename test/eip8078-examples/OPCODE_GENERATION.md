# EIP-8078 Code Generation - Opcode Mapping

This document explains how the Solidity compiler generates bytecode for EIP-8078 subscribe and unsubscribe statements.

## Opcode Summary

| Statement | Opcode | Hex | Stack Input | Stack Output |
|-----------|--------|-----|-------------|--------------|
| `subscribe` | SUBSCRIBE | 0x5c | [targetAddress, eventSig, subscriberAddress, callbackSelector, gasLimit, gasPrice] | [subscriptionId] |
| `unsubscribe` | UNSUBSCRIBE | 0x5d | [targetAddress, eventSig, subscriberAddress] | [success] |
| Event emission | NOTIFYSUBSCRIBERS | 0x5e | [eventSig, dataOffset, dataSize] | [numNotified] |

## Subscribe Statement

### Solidity Source:
```solidity
subscribe oracle.PriceUpdated(newPrice)
    with onPriceUpdate(newPrice)
    gasLimit 100000
    gasPrice 20 gwei;
```

### Generated Yul IR:
```yul
{
    let subscriptionId := verbatim_6i_1o(
        hex"5c",                    // SUBSCRIBE opcode
        <targetAddress>,            // oracle contract address
        <eventSig>,                 // keccak256("PriceUpdated(uint256)")
        address(),                  // subscriber (this contract)
        <callbackSelector>,         // keccak256("onPriceUpdate()")
        <gasLimit>,                 // 100000
        <gasPrice>                  // 20 gwei
    )
}
```

### Bytecode (example):
```
PUSH20 0x... (targetAddress)
PUSH32 0x... (eventSig)
ADDRESS      (subscriber address)
PUSH32 0x... (callbackSelector)
PUSH3  0x0186a0  (100000 gas)
PUSH10 0x04a817c800 (20 gwei)
0x5c         (SUBSCRIBE opcode)
```

### What the Compiler Does:

1. **Extract Target Address:**
   - Parses `oracle` from `oracle.PriceUpdated()`
   - Generates code to load the oracle contract address

2. **Calculate Event Signature:**
   - Gets event parameters from EventDefinition
   - Calculates: `keccak256("PriceUpdated(uint256)")`
   - Result: `0x8cedca10c07e393bc7de5e8de57ab721e7cd42d34a34d4e53f93b5e4e1bea2a5`

3. **Get Subscriber Address:**
   - Generates `address()` to get current contract

4. **Calculate Callback Selector:**
   - Takes callback function name from `with onPriceUpdate(newPrice)`
   - Calculates: `keccak256("onPriceUpdate()")`
   - Result: First 4 bytes used as selector

5. **Load Gas Parameters:**
   - Evaluates `gasLimit` expression (100000)
   - Evaluates `gasPrice` expression (20 gwei)

6. **Emit SUBSCRIBE Opcode:**
   - Uses Yul `verbatim_6i_1o` for custom opcode
   - 6 inputs, 1 output
   - Opcode hex: `0x5c`

## Unsubscribe Statement

### Solidity Source:
```solidity
unsubscribe oracle.PriceUpdated;
```

### Generated Yul IR:
```yul
{
    let success := verbatim_3i_1o(
        hex"5d",                    // UNSUBSCRIBE opcode
        <targetAddress>,            // oracle contract address
        <eventSig>,                 // keccak256("PriceUpdated(uint256)")
        address()                   // subscriber (this contract)
    )
}
```

### Bytecode (example):
```
PUSH20 0x... (targetAddress)
PUSH32 0x... (eventSig)
ADDRESS      (subscriber address)
0x5d         (UNSUBSCRIBE opcode)
```

### What the Compiler Does:

1. **Extract Target Address:**
   - Parses `oracle` from `oracle.PriceUpdated`
   - Generates code to load the oracle contract address

2. **Calculate Event Signature:**
   - Gets event definition from MemberAccess
   - Calculates: `keccak256("PriceUpdated(uint256)")`

3. **Get Subscriber Address:**
   - Generates `address()` to get current contract

4. **Emit UNSUBSCRIBE Opcode:**
   - Uses Yul `verbatim_3i_1o` for custom opcode
   - 3 inputs, 1 output
   - Opcode hex: `0x5d`

## Event Emission (NOTIFYSUBSCRIBERS)

**Note:** This opcode is NOT yet implemented in the compiler. It should be called automatically during event emission.

### Expected Integration:

When a subscribable event is emitted, the compiler should add NOTIFYSUBSCRIBERS after the LOG opcode:

```yul
// Current event emission (PriceUpdated)
log1(memPos, dataSize, eventSignature)

// Should also call:
verbatim_3i_1o(
    hex"5e",           // NOTIFYSUBSCRIBERS opcode
    eventSignature,
    memPos,
    dataSize
)
```

This would be added to the Event case in `IRGeneratorForStatements::endVisit(FunctionCall)`.

## Verbatim Opcodes in Yul

The compiler uses Yul's `verbatim` feature to inject custom opcodes:

- `verbatim_6i_1o(hex, arg1, arg2, arg3, arg4, arg5, arg6)` - 6 inputs, 1 output
- `verbatim_3i_1o(hex, arg1, arg2, arg3)` - 3 inputs, 1 output

The `hex` string specifies the raw opcode bytes.

## Stack Layout Details

### SUBSCRIBE (0x5c)
```
Before: [targetAddress, eventSig, subscriberAddress, callbackSelector, gasLimit, gasPrice]
After:  [subscriptionId]

Example:
  targetAddress:     0x1234567890123456789012345678901234567890
  eventSig:          0x8cedca10c07e393bc7de5e8de57ab721e7cd42d34a34d4e53f93b5e4e1bea2a5
  subscriberAddress: 0x9876543210987654321098765432109876543210
  callbackSelector:  0x12345678
  gasLimit:          100000
  gasPrice:          20000000000 (20 gwei)

  Returns: subscriptionId (uint256)
```

### UNSUBSCRIBE (0x5d)
```
Before: [targetAddress, eventSig, subscriberAddress]
After:  [success]

Example:
  targetAddress:     0x1234567890123456789012345678901234567890
  eventSig:          0x8cedca10c07e393bc7de5e8de57ab721e7cd42d34a34d4e53f93b5e4e1bea2a5
  subscriberAddress: 0x9876543210987654321098765432109876543210

  Returns: success (1 = success, 0 = failure)
```

## Geth Implementation Requirements

Your Geth fork must implement these opcodes with the exact stack signatures above:

### SUBSCRIBE (0x5c)
```go
func opSubscribe(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error) {
    stack := scope.Stack

    targetAddress := common.Address(stack.pop().Bytes20())
    eventSig := stack.pop()
    subscriberAddress := common.Address(stack.pop().Bytes20())
    callbackSelector := stack.pop()
    gasLimit := stack.pop()
    gasPrice := stack.pop()

    // Create subscription
    subscriptionId := interpreter.evm.SubscriptionManager.Subscribe(
        targetAddress,
        eventSig,
        subscriberAddress,
        callbackSelector,
        gasLimit,
        gasPrice,
    )

    stack.push(subscriptionId)
    return nil, nil
}
```

### UNSUBSCRIBE (0x5d)
```go
func opUnsubscribe(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error) {
    stack := scope.Stack

    targetAddress := common.Address(stack.pop().Bytes20())
    eventSig := stack.pop()
    subscriberAddress := common.Address(stack.pop().Bytes20())

    // Remove subscription
    success := interpreter.evm.SubscriptionManager.Unsubscribe(
        targetAddress,
        eventSig,
        subscriberAddress,
    )

    if success {
        stack.push(new(uint256.Int).SetUint64(1))
    } else {
        stack.push(new(uint256.Int).SetUint64(0))
    }
    return nil, nil
}
```

## Testing the Generated Code

### 1. Compile a Contract:
```bash
./build/solc/solc --bin --abi --ir ../test/eip8078-examples/DerivedProtocol.sol > output.txt
```

### 2. Check for Verbatim Opcodes:
```bash
grep -A 5 "verbatim_6i_1o\|verbatim_3i_1o" output.txt
```

Expected output shows:
- `hex"5c"` for SUBSCRIBE
- `hex"5d"` for UNSUBSCRIBE

### 3. Inspect Bytecode:
```bash
grep "Binary:" output.txt
```

Look for:
- `5c` byte in the bytecode (SUBSCRIBE)
- `5d` byte in the bytecode (UNSUBSCRIBE)

## Example Full Compilation

### Source (DerivedProtocol.sol):
```solidity
contract DerivedProtocol {
    PriceOracle public oracle;

    constructor(address _oracle) payable {
        oracle = PriceOracle(_oracle);

        subscribe oracle.PriceUpdated(newPrice)
            with onPriceUpdate(newPrice)
            gasLimit 100000
            gasPrice 20 gwei;
    }

    function cleanup() external {
        unsubscribe oracle.PriceUpdated;
    }
}
```

### Generated IR (simplified):
```yul
object "DerivedProtocol" {
    code {
        // Constructor
        {
            // ... setup code ...

            // Subscribe statement
            let subscriptionId := verbatim_6i_1o(
                hex"5c",
                sload(0),  // oracle address from storage
                0x8cedca10c07e393bc7de5e8de57ab721e7cd42d34a34d4e53f93b5e4e1bea2a5,
                address(),
                0x12345678,  // callback selector
                100000,
                20000000000
            )
        }
    }

    object "DerivedProtocol_deployed" {
        code {
            // cleanup() function
            function fun_cleanup() {
                let success := verbatim_3i_1o(
                    hex"5d",
                    sload(0),  // oracle address
                    0x8cedca10c07e393bc7de5e8de57ab721e7cd42d34a34d4e53f93b5e4e1bea2a5,
                    address()
                )
            }
        }
    }
}
```

## Summary

The Solidity compiler now:
1. ✅ Parses subscribe/unsubscribe statements
2. ✅ Generates IR code with verbatim opcodes
3. ✅ Emits SUBSCRIBE (0x5c) with 6 parameters
4. ✅ Emits UNSUBSCRIBE (0x5d) with 3 parameters
5. ⏳ NOTIFYSUBSCRIBERS (0x5e) - Not yet implemented

The generated bytecode is ready to run on your EIP-8078 modified Geth!
