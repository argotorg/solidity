// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

/// Internal calls compiled to EIP-7979 CALLSUB / CALLDEST / RETURNSUB.
contract Calls {
    function square(uint256 x) internal pure returns (uint256) {
        return x * x;
    }

    function sumOfSquares(uint256 a, uint256 b) internal pure returns (uint256) {
        return square(a) + square(b);
    }

    function factorial(uint256 n) internal pure returns (uint256) {
        if (n < 2) return 1;
        return n * factorial(n - 1);
    }

    function compute(uint256 a, uint256 b) external pure returns (uint256) {
        return sumOfSquares(a, b) + factorial(b);
    }
}
