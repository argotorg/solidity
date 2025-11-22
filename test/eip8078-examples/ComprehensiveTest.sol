// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ComprehensiveTest
 * @notice Comprehensive test contract for EIP-8078 features
 * @dev Tests various aspects of subscribable events and subscriptions
 */
contract ComprehensiveTest {
    // Test 1: Basic subscribable event
    event subscribable BasicEvent(uint256 value) gasHint(30000);

    // Test 2: Subscribable event with multiple parameters
    event subscribable MultiParamEvent(
        address indexed sender,
        uint256 value,
        string message
    ) gasHint(80000);

    // Test 3: Subscribable event with all indexed parameters
    event subscribable AllIndexedEvent(
        address indexed param1,
        uint256 indexed param2,
        bytes32 indexed param3
    ) gasHint(40000);

    // Test 4: Anonymous subscribable event
    event subscribable anonymous AnonymousEvent(uint256 value) gasHint(25000);

    // Test 5: Subscribable event without gasHint
    event subscribable NoGasHintEvent(uint256 value);

    // Test 6: Regular (non-subscribable) event for comparison
    event RegularEvent(uint256 value);

    // State for testing
    uint256 public counter;

    /**
     * @notice Emit basic subscribable event
     */
    function emitBasicEvent(uint256 value) external {
        emit BasicEvent(value);
        counter++;
    }

    /**
     * @notice Emit multi-parameter subscribable event
     */
    function emitMultiParamEvent(uint256 value, string memory message) external {
        emit MultiParamEvent(msg.sender, value, message);
        counter++;
    }

    /**
     * @notice Emit all-indexed subscribable event
     */
    function emitAllIndexedEvent(
        address param1,
        uint256 param2,
        bytes32 param3
    ) external {
        emit AllIndexedEvent(param1, param2, param3);
        counter++;
    }

    /**
     * @notice Emit anonymous subscribable event
     */
    function emitAnonymousEvent(uint256 value) external {
        emit AnonymousEvent(value);
        counter++;
    }

    /**
     * @notice Emit subscribable event without gas hint
     */
    function emitNoGasHintEvent(uint256 value) external {
        emit NoGasHintEvent(value);
        counter++;
    }

    /**
     * @notice Emit regular (non-subscribable) event
     */
    function emitRegularEvent(uint256 value) external {
        emit RegularEvent(value);
        counter++;
    }

    /**
     * @notice Emit multiple events in one transaction
     */
    function emitMultipleEvents(uint256 value) external {
        emit BasicEvent(value);
        emit RegularEvent(value);
        emit NoGasHintEvent(value + 1);
        counter++;
    }
}

/**
 * @title EventSubscriber
 * @notice Contract that subscribes to ComprehensiveTest events
 * @dev Tests subscription functionality
 */
contract EventSubscriber {
    ComprehensiveTest public emitter;

    // Special dispatcher address
    address constant SUBSCRIPTION_DISPATCHER = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    // Tracking state
    uint256 public basicEventCount;
    uint256 public multiParamEventCount;
    uint256 public lastReceivedValue;
    string public lastReceivedMessage;
    uint256 public depositBalance;

    event CallbackExecuted(string eventType, uint256 value);

    modifier onlyEventCallback() {
        require(msg.sender == SUBSCRIPTION_DISPATCHER, "Only event callbacks");
        _;
    }

    constructor(address _emitter) payable {
        emitter = ComprehensiveTest(_emitter);
        depositBalance = msg.value;

        // Subscribe to BasicEvent
        // subscribe emitter.BasicEvent(value)
        //     with onBasicEvent(value)
        //     gasLimit 80000
        //     gasPrice 20 gwei;

        // Subscribe to MultiParamEvent
        // subscribe emitter.MultiParamEvent(sender, value, message)
        //     with onMultiParamEvent(sender, value, message)
        //     gasLimit 120000
        //     gasPrice 20 gwei;
    }

    /**
     * @notice Callback for BasicEvent
     */
    function onBasicEvent(uint256 value)
        external
        payable
        onlyEventCallback
    {
        basicEventCount++;
        lastReceivedValue = value;

        // Process gas refund
        if (msg.value > 0) {
            depositBalance += msg.value;
        }

        emit CallbackExecuted("BasicEvent", value);
    }

    /**
     * @notice Callback for MultiParamEvent
     */
    function onMultiParamEvent(
        address sender,
        uint256 value,
        string memory message
    )
        external
        payable
        onlyEventCallback
    {
        multiParamEventCount++;
        lastReceivedValue = value;
        lastReceivedMessage = message;

        // Process gas refund
        if (msg.value > 0) {
            depositBalance += msg.value;
        }

        emit CallbackExecuted("MultiParamEvent", value);
    }

    /**
     * @notice Unsubscribe from all events
     */
    function unsubscribeAll() external {
        // unsubscribe emitter.BasicEvent;
        // unsubscribe emitter.MultiParamEvent;
    }

    receive() external payable {
        depositBalance += msg.value;
    }
}

/**
 * @title FailingSubscriber
 * @notice Contract with callback that intentionally fails
 * @dev Tests graceful failure handling
 */
contract FailingSubscriber {
    ComprehensiveTest public emitter;
    address constant SUBSCRIPTION_DISPATCHER = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    bool public shouldFail = true;

    event CallbackFailed();

    modifier onlyEventCallback() {
        require(msg.sender == SUBSCRIPTION_DISPATCHER, "Only event callbacks");
        _;
    }

    constructor(address _emitter) payable {
        emitter = ComprehensiveTest(_emitter);

        // Subscribe with intent to fail
        // subscribe emitter.BasicEvent(value)
        //     with onBasicEventFail(value)
        //     gasLimit 50000
        //     gasPrice 20 gwei;
    }

    /**
     * @notice Callback that intentionally reverts
     */
    function onBasicEventFail(uint256 value)
        external
        payable
        onlyEventCallback
    {
        if (shouldFail) {
            emit CallbackFailed();
            revert("Intentional failure");
        }
    }

    function setShouldFail(bool _shouldFail) external {
        shouldFail = _shouldFail;
    }

    receive() external payable {}
}
