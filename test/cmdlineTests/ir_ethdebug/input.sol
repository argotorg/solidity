// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;

contract C {
    uint256 counter;
    mapping(address => uint256) balances;

    function f(uint256 argument) public returns (uint256 result) {
        counter += argument;
        result = balances[msg.sender] + counter;
    }
}
