// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PriceOracle
 * @notice Example contract demonstrating EIP-8078 subscribable events
 * @dev This oracle emits price updates that other contracts can subscribe to
 */
contract PriceOracle {
    uint256 public price;
    address public owner;

    // Subscribable event with gas hint
    event subscribable PriceUpdated(uint256 newPrice) gasHint(50000);

    // Regular event for comparison
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        price = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @notice Update the price and emit subscribable event
     * @param _price The new price value
     */
    function updatePrice(uint256 _price) external onlyOwner {
        uint256 oldPrice = price;
        price = _price;
        emit PriceUpdated(_price);
    }

    /**
     * @notice Transfer ownership
     * @param newOwner The new owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
