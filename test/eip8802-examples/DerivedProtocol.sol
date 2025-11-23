// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PriceOracle.sol";

/**
 * @title DerivedProtocol
 * @notice Example contract that subscribes to PriceOracle events
 * @dev Demonstrates EIP-8802 subscription functionality
 */
contract DerivedProtocol {
    PriceOracle public oracle;
    uint256 public lastSyncedPrice;
    uint256 public depositBalance;
    uint256 public callbackCount;

    // Special dispatcher address for event callbacks
    address constant SUBSCRIPTION_DISPATCHER = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    event PriceSynced(uint256 price);
    event SubscriptionGasRefund(uint256 amount);
    event PositionRebalanced(uint256 price);

    modifier onlyEventCallback() {
        require(msg.sender == SUBSCRIPTION_DISPATCHER, "Only event callbacks");
        _;
    }

    /**
     * @notice Constructor that subscribes to oracle price updates
     * @param _oracle The oracle contract address
     */
    constructor(address _oracle) payable {
        oracle = PriceOracle(_oracle);

        // Subscribe to price updates
        // Note: This is the syntax defined in EIP-8802
        // subscribe oracle.PriceUpdated(newPrice)
        //     with onPriceUpdate(newPrice)
        //     gasLimit 100000
        //     gasPrice 20 gwei;

        // Deposit gas payment
        depositBalance = msg.value;
    }

    /**
     * @notice Callback function automatically called when PriceUpdated is emitted
     * @param newPrice The new price from the oracle
     * @dev This function is called by the subscription dispatcher
     */
    function onPriceUpdate(uint256 newPrice)
        external
        payable
        onlyEventCallback
    {
        callbackCount++;
        lastSyncedPrice = newPrice;
        emit PriceSynced(newPrice);

        // Process gas refund if any
        if (msg.value > 0) {
            depositBalance += msg.value;
            emit SubscriptionGasRefund(msg.value);
        }

        // Perform derivative calculations
        rebalancePositions(newPrice);
    }

    /**
     * @notice Rebalance positions based on new price
     * @param newPrice The new price to base rebalancing on
     * @dev If this reverts, the oracle's updatePrice() still succeeds
     */
    function rebalancePositions(uint256 newPrice) internal {
        // Complex logic that might fail
        // Failures are graceful and logged

        // Simple example: only rebalance if price changed significantly
        if (lastSyncedPrice > 0) {
            uint256 percentChange = (newPrice > lastSyncedPrice)
                ? ((newPrice - lastSyncedPrice) * 100) / lastSyncedPrice
                : ((lastSyncedPrice - newPrice) * 100) / lastSyncedPrice;

            if (percentChange >= 5) {
                emit PositionRebalanced(newPrice);
            }
        }
    }

    /**
     * @notice Withdraw unused deposit
     * @param amount The amount to withdraw
     */
    function withdrawDeposit(uint256 amount) external {
        require(depositBalance >= amount, "Insufficient balance");
        depositBalance -= amount;
        payable(msg.sender).transfer(amount);
    }

    /**
     * @notice Cleanup subscription
     */
    function cleanup() external {
        // Unsubscribe from price updates
        // unsubscribe oracle.PriceUpdated;
    }

    /**
     * @notice Get subscription status
     * @return Whether this contract is subscribed
     */
    function getSubscriptionStatus() external view returns (bool) {
        // This would check subscription state
        // return isSubscribedTo(address(oracle), "PriceUpdated");
        return true; // Placeholder
    }

    receive() external payable {
        depositBalance += msg.value;
    }
}
