// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract C {
    function mask(uint x) public pure returns (uint) {
        return x & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function small(uint x) public pure returns (uint) {
        return x & 0xffffff;
    }
}
