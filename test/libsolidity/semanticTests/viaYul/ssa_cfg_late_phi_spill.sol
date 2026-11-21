// A loop header whose phis are created after the operations of the loop condition (`add(b1, b2)`, `lt`), with
// 17 values kept live across the body: the SSA CFG layout spills the phis there, which are stored where their
// shadows are written on entry of the header.
contract C {
    function f(uint b1, uint b2, uint b3, uint b4, uint b5, uint b6, uint b7, uint b8, uint b9, uint b10, uint b11, uint b12, uint b13, uint b14, uint b15, uint b16, uint b17) public returns (uint sum) {
        assembly {
            for { let i := 0 } lt(i, add(b1, b2)) { i := add(i, 1) } {
                sstore(i, b17)
                sstore(add(i, 1), b16)
                sstore(add(i, 2), b15)
                sstore(add(i, 3), b14)
                sstore(add(i, 4), b13)
                sstore(add(i, 5), b12)
                sstore(add(i, 6), b11)
                sstore(add(i, 7), b10)
                sstore(add(i, 8), b9)
                sstore(add(i, 9), b8)
                sstore(add(i, 10), b7)
                sstore(add(i, 11), b6)
                sstore(add(i, 12), b5)
                sstore(add(i, 13), b4)
                sstore(add(i, 14), b3)
                sstore(add(i, 15), b2)
                sstore(add(i, 16), b1)
            }
        }
        for (uint k = 0; k < 19; k++) {
            uint v;
            assembly { v := sload(k) }
            sum += v * (k + 1);
        }
    }
}
// ====
// compileViaYul: true
// ----
// f(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 -> 1326
// gas irOptimized: 452763
// gas ssaCFGOptimized: 453156
