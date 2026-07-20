// SPDX-License-Identifier: GPL-3.0
pragma solidity *;

// Regression test for stack-to-memory spilling miscompilation SOL-2026-2 caused by the call graph cycle detection
// misclassifying functions in intersecting recursive cycles.
//
// Call graph:  a -> {b, c},  b -> a,  c -> b
// so {a, b, c} is a single strongly-connected component and all three functions are recursive, spilling is unsound.
// The stack limit evader must refuse to spill here.
contract C {
    uint256[26] public seed;

    function trigger() external returns (uint256 storedAt3) {
        a(3);
        storedAt3 = seed[3];
    }

    function a(uint256 m) internal {
        if (m == 0) return;
        b(m);
        c(m);
    }
    function b(uint256 m) internal {
        if (m == 0) return;
        a(m - 1);
    }
    function c(uint256 m) internal {
        if (m == 0) return;
        uint256 v1  = seed[0] ^ m;
        uint256 v2  = seed[1] ^ m;
        uint256 v3  = seed[2] ^ m;
        uint256 v4  = seed[3] ^ m;
        uint256 v5  = seed[4] ^ m;
        uint256 v6  = seed[5] ^ m;
        uint256 v7  = seed[6] ^ m;
        uint256 v8  = seed[7] ^ m;
        uint256 v9  = seed[8] ^ m;
        uint256 v10 = seed[9] ^ m;
        uint256 v11 = seed[10] ^ m;
        uint256 v12 = seed[11] ^ m;
        uint256 v13 = seed[12] ^ m;
        uint256 v14 = seed[13] ^ m;
        uint256 v15 = seed[14] ^ m;
        uint256 v16 = seed[15] ^ m;
        uint256 v17 = seed[16] ^ m;
        uint256 v18 = seed[17] ^ m;
        uint256 v19 = seed[18] ^ m;
        uint256 v20 = seed[19] ^ m;
        uint256 v21 = seed[20] ^ m;
        uint256 v22 = seed[21] ^ m;
        uint256 v23 = seed[22] ^ m;
        uint256 v24 = seed[23] ^ m;
        uint256 v25 = seed[24] ^ m;

        b(m - 1);

        // Read m back, provoking a stack too deep situation
        seed[m] = m;
        // Keep v1..v25 alive across the b(m - 1) call
        seed[25] =
            v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 +
            v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20 +
            v21 + v22 + v23 + v24 + v25;
    }
}
