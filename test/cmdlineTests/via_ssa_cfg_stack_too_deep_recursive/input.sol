// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;

contract C {
    function q(uint256 n) internal returns (uint256) {
        if (n == 0)
            return 0;
        uint256 a0 = n + 0; uint256 a1 = n + 1; uint256 a2 = n + 2; uint256 a3 = n + 3;
        uint256 a4 = n + 4; uint256 a5 = n + 5; uint256 a6 = n + 6; uint256 a7 = n + 7;
        uint256 a8 = n + 8; uint256 a9 = n + 9; uint256 a10 = n + 10; uint256 a11 = n + 11;
        uint256 a12 = n + 12; uint256 a13 = n + 13; uint256 a14 = n + 14; uint256 a15 = n + 15;
        uint256 a16 = n + 16;
        return
            a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16 +
            q(n - 1);
    }

    function f(uint256 n) public returns (uint256) {
        return q(n);
    }
}
