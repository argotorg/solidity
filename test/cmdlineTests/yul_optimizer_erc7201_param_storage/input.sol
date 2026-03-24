// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;
contract C {
    string namespace = "example.main";
    function f() public view returns (uint) {
        // Conversion of input from storage to memory
        // requires encoding which will appear in the IR output
        return erc7201(namespace);
    }
}
