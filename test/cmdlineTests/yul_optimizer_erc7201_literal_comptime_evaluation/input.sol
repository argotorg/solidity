// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;
contract C {
    function f() public pure returns (uint) {
        // IR output should contain the value calculated in compile time:
        // 0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500
        return erc7201("example.main");
    }
}
