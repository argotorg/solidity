// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Test that library function is preferred over native property when called with parentheses.
// This allows library functions like `balance()` to work alongside native `address.balance`.
library AddressUtils {
    function balance(address a) internal view returns (uint256) {
        return a.balance / 1e18;
    }
}

contract C {
    using AddressUtils for address;

    function getBalance(address a) public view returns (uint256) {
        // With parentheses - should use library function
        return a.balance();
    }
}
// ----
