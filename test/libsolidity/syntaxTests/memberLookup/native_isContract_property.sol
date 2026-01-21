// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Test Tron's native address.isContract property works without library.
contract C {
    function check(address a) public view returns (bool) {
        return a.isContract;
    }
}
// ----
