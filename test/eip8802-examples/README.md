# EIP-8802 Event Subscription Examples

This directory contains example contracts demonstrating EIP-8802 (Contract Event Subscription) features implemented in the Solidity compiler.

## Overview

EIP-8802 introduces a mechanism for smart contracts to subscribe to events emitted by other contracts and automatically execute callback functions when those events occur.

## Example Contracts

### 1. PriceOracle.sol
A simple price oracle that emits subscribable price updates.

**Features:**
- Subscribable `PriceUpdated` event with `gasHint(50000)`
- Demonstrates basic event declaration syntax

**Usage:**
```solidity
event subscribable PriceUpdated(uint256 newPrice) gasHint(50000);
```

### 2. DerivedProtocol.sol
A protocol that subscribes to the PriceOracle and reacts to price changes.

**Features:**
- Subscribes to `PriceUpdated` event in constructor
- Implements callback function with `onlyEventCallback` modifier
- Handles gas deposits and refunds
- Demonstrates graceful failure (rebalancing logic can fail without reverting oracle)

**Subscription Syntax:**
```solidity
subscribe oracle.PriceUpdated(newPrice)
    with onPriceUpdate(newPrice)
    gasLimit 100000
    gasPrice 20 gwei;
```

### 3. SimpleToken.sol
An ERC20-like token with subscribable Transfer and Approval events.

**Features:**
- Multiple subscribable events
- Multi-parameter events with indexed parameters
- Demonstrates event subscription for token monitoring

### 4. TokenWatcher.sol
Monitors token transfers by subscribing to Transfer events.

**Features:**
- Tracks sent/received amounts for a watched address
- Demonstrates subscribing to events with multiple indexed parameters
- Real-time transaction monitoring without off-chain infrastructure

### 5. ComprehensiveTest.sol
Comprehensive test contract covering all EIP-8802 features.

**Features:**
- Basic subscribable events
- Multi-parameter events
- All-indexed events
- Anonymous subscribable events
- Events without gasHint
- Multiple subscribers (EventSubscriber)
- Failing callbacks (FailingSubscriber)

## Key Concepts

### Subscribable Events

Events can be marked as `subscribable` to enable on-chain subscriptions:

```solidity
event subscribable EventName(parameters) gasHint(gasAmount);
```

The `gasHint` annotation is optional but recommended to help subscribers estimate gas costs.

### Event Subscription

Contracts subscribe to events using the `subscribe` statement:

```solidity
subscribe targetContract.EventName(params)
    with callbackFunction(params)
    gasLimit 100000
    gasPrice 20 gwei;
```

### Callback Functions

Callback functions must:
- Be `external`
- Be `payable` (to receive gas refunds)
- Use the `onlyEventCallback` modifier
- Match event parameter types

```solidity
function onEventName(params)
    external
    payable
    onlyEventCallback
{
    // Handle event
}
```

### Special Dispatcher Address

Callbacks are invoked by a special dispatcher address:
```solidity
address constant SUBSCRIPTION_DISPATCHER = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
```

### Unsubscribing

Subscriptions can be removed:

```solidity
unsubscribe targetContract.EventName;
```

## Alignment with EIP-8802 Specification

**Note:** The EIP document references "EIP-8082" but the implementation uses "EIP-8802". This appears to be a documentation discrepancy.

### Implemented Features

✅ **Subscribable Event Declaration**
- `subscribable` keyword on events
- `gasHint(uint256)` annotation
- Compiler parsing and validation

✅ **ABI Extension**
- `subscribable` flag in event ABI
- `gasHint` value in event ABI
- Backward compatibility maintained

✅ **AST Support**
- EventDefinition extended with subscribable flag and gasHint
- SubscribeStatement AST node
- UnsubscribeStatement AST node

### Pending Runtime Features

The following features are defined in the compiler but require EVM/runtime support:

⏳ **Subscribe/Unsubscribe Opcodes**
- SUBSCRIBE (0x5c) - Requires EVM implementation
- UNSUBSCRIBE (0x5d) - Requires EVM implementation
- NOTIFYSUBSCRIBERS (0x5e) - Requires EVM implementation

⏳ **Subscription Execution**
- Isolated callback execution context
- Gas accounting and deposits
- Graceful failure handling

⏳ **Built-in Functions**
- `isSubscribedTo(address, string)`
- `getSubscription(address, string)`
- `updateSubscription(...)`

## Testing

The example contracts demonstrate:

1. **Syntax Validation** - All contracts compile with the extended syntax
2. **ABI Generation** - Subscribable events appear correctly in contract ABIs
3. **Multiple Use Cases** - Price oracles, token monitoring, multi-subscriber scenarios
4. **Edge Cases** - Anonymous events, events without gasHint, failing callbacks

## Compilation

To compile the example contracts:

```bash
solc --bin --abi test/eip8802-examples/*.sol
```

To view the ABI with subscribable metadata:

```bash
solc --abi test/eip8802-examples/PriceOracle.sol | jq '.[] | select(.name=="PriceUpdated")'
```

Expected output:
```json
{
  "type": "event",
  "name": "PriceUpdated",
  "inputs": [
    {
      "name": "newPrice",
      "type": "uint256",
      "indexed": false
    }
  ],
  "anonymous": false,
  "subscribable": true,
  "gasHint": "50000"
}
```

## Future Work

For full EIP-8802 support, the following components need implementation:

1. **Go-Ethereum (Geth)**
   - New opcodes (SUBSCRIBE, UNSUBSCRIBE, NOTIFYSUBSCRIBERS)
   - Subscription state management
   - Callback execution engine
   - Gas accounting system

2. **Solidity Compiler**
   - Code generation for subscribe/unsubscribe statements
   - Built-in subscription management functions
   - Subscription optimizer

3. **Testing Infrastructure**
   - Semantic tests for subscription behavior
   - Gas cost benchmarks
   - Security test suite

## References

- EIP-8802 Specification (referenced as EIP-8082 in some documents)
- Pull Request: https://github.com/argotorg/solidity/pull/16289
- Implementation Discussion: https://ethereum-magicians.org/t/eip-to-be-assigned-contract-event-subscription/26575
