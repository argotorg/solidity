// SPDX-License-Identifier: GPL-2.0
pragma solidity >=0.0;

contract C {
    uint256 transient varTransient;
    uint256 public varStorage = 0xeeeeeeeeee;

    function foo() external returns (uint256) {
        varTransient = 0xffffffff;
        delete varTransient;
        delete varStorage;

        return varStorage;
    }
}
