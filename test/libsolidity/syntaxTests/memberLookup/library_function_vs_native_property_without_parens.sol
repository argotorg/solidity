// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Test that accessing a member without parentheses when both a native property
// and a library function exist with the same name results in an ambiguity error.
// Users should use the native property syntax directly without "using for" to avoid this.
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract C {
    using Address for address;

    function check(address a) public view returns (bool) {
        // Without parentheses - ambiguous between native property and library function
        return a.isContract;
    }
}
// ----
// TypeError 6675: (519-531): Member "isContract" not unique after argument-dependent lookup in address.
