// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract C {
    uint private s;

    function mask(uint x) public {
        s = x & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }
}
