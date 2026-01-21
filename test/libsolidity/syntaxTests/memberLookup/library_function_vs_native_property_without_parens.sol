// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Test that accessing a member without parentheses when both a native property
// and a library function exist with the same name results in an ambiguity error.
// Users should access the native property directly without "using for" to avoid this.
library AddressUtils {
    function balance(address a) internal view returns (uint256) {
        return a.balance / 1e18;
    }
}

contract C {
    using AddressUtils for address;

    function getBalance(address a) public view returns (uint256) {
        // Without parentheses - ambiguous between native property and library function
        return a.balance;
    }
}
// ----
// TypeError 6675: (517-526): Member "balance" not unique after argument-dependent lookup in address.
