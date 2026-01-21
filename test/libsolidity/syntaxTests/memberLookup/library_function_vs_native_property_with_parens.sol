// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Test that library function is preferred over native property when called with parentheses.
// This allows OpenZeppelin's Address.isContract() to work alongside Tron's native address.isContract property.
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract C {
    using Address for address;

    function check(address a) public view returns (bool) {
        // With parentheses - should use library function
        return a.isContract();
    }
}
// ----
