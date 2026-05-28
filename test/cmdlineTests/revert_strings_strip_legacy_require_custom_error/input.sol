// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;
contract C {
    error MyError(uint errorCode, string errorMsg, bool flag);
    function flag() pure public returns (bool) { return false; }
    function f() pure external {
        uint code = 8;
        string memory eMsg = "error";
        require(false, MyError(code, eMsg, flag()));
    }
}
