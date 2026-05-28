// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;
contract C {
    error MyError(uint errorCode, string errorMsg);
    uint public counter = 0;
    function count() public returns (uint) { return ++counter; }
    function f() external {
        string memory eMsg = "error";
        require(false, MyError(count(), eMsg));
        counter += 2;
    }
}
