// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;
contract C {
    function f(string calldata id) public pure returns (uint) {
        // Conversion of input from calldata to memory
        // requires encoding which will appear in the IR output
        return erc7201(id);
    }
}
