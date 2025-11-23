// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SimpleToken.sol";

/**
 * @title TokenWatcher
 * @notice Contract that monitors token transfers via event subscription
 * @dev Demonstrates subscribing to multi-parameter events
 */
contract TokenWatcher {
    SimpleToken public token;
    address public watchedAddress;

    uint256 public totalReceived;
    uint256 public totalSent;
    uint256 public transactionCount;

    // Special dispatcher address for event callbacks
    address constant SUBSCRIPTION_DISPATCHER = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    event TransferDetected(address indexed from, address indexed to, uint256 value);
    event WatchedAddressActivity(string action, uint256 value);

    modifier onlyEventCallback() {
        require(msg.sender == SUBSCRIPTION_DISPATCHER, "Only event callbacks");
        _;
    }

    /**
     * @notice Constructor that subscribes to token transfers
     * @param _token The token contract to watch
     * @param _watchedAddress The address to monitor
     */
    constructor(address _token, address _watchedAddress) payable {
        token = SimpleToken(_token);
        watchedAddress = _watchedAddress;

        // Subscribe to Transfer events
        // subscribe token.Transfer(from, to, value)
        //     with onTransfer(from, to, value)
        //     gasLimit 150000
        //     gasPrice 20 gwei;
    }

    /**
     * @notice Callback for Transfer events
     * @param from The sender address
     * @param to The recipient address
     * @param value The transfer amount
     */
    function onTransfer(
        address from,
        address to,
        uint256 value
    )
        external
        payable
        onlyEventCallback
    {
        transactionCount++;

        // Track activity for watched address
        if (from == watchedAddress) {
            totalSent += value;
            emit WatchedAddressActivity("sent", value);
        }

        if (to == watchedAddress) {
            totalReceived += value;
            emit WatchedAddressActivity("received", value);
        }

        emit TransferDetected(from, to, value);
    }

    /**
     * @notice Get statistics for watched address
     * @return sent Total amount sent by watched address
     * @return received Total amount received by watched address
     * @return txCount Total number of transactions involving watched address
     */
    function getStatistics()
        external
        view
        returns (
            uint256 sent,
            uint256 received,
            uint256 txCount
        )
    {
        return (totalSent, totalReceived, transactionCount);
    }

    receive() external payable {}
}
