// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;
contract C {
    function f() public pure returns (uint) {
        // No encoding necessary, IR output will show value
        // loaded directly from memory.
        string memory namespaceID = "example.main";
        return erc7201(namespaceID);
    }
}
