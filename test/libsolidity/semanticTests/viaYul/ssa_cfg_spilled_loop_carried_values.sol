// Loop-carried values beyond the reachable stack depth: the SSA CFG layout spills loop phis, each sharing its
// memory slot with its shadow slot and stored where the shadow slot is written, and the values feeding them.
contract C {
    function f(uint x) public returns (uint r) {
        assembly {
            let a0 := 0
            let a1 := 1
            let a2 := 2
            let a3 := 3
            let a4 := 4
            let a5 := 5
            let a6 := 6
            let a7 := 7
            let a8 := 8
            let a9 := 9
            let a10 := 10
            let a11 := 11
            let a12 := 12
            let a13 := 13
            let a14 := 14
            let a15 := 15
            let a16 := 16
            let a17 := 17
            let a18 := 18
            for { let i := 0 } lt(i, x) { i := add(i, 1) } {
                a0 := add(a0, add(i, 0))
                a1 := add(a1, add(i, 1))
                a2 := add(a2, add(i, 2))
                a3 := add(a3, add(i, 3))
                a4 := add(a4, add(i, 4))
                a5 := add(a5, add(i, 5))
                a6 := add(a6, add(i, 6))
                a7 := add(a7, add(i, 7))
                a8 := add(a8, add(i, 8))
                a9 := add(a9, add(i, 9))
                a10 := add(a10, add(i, 10))
                a11 := add(a11, add(i, 11))
                a12 := add(a12, add(i, 12))
                a13 := add(a13, add(i, 13))
                a14 := add(a14, add(i, 14))
                a15 := add(a15, add(i, 15))
                a16 := add(a16, add(i, 16))
                a17 := add(a17, add(i, 17))
                a18 := add(a18, add(i, 18))
            }
            r := add(add(add(add(add(add(add(add(add(add(add(add(add(add(add(add(add(add(a0, a1), a2), a3), a4), a5), a6), a7), a8), a9), a10), a11), a12), a13), a14), a15), a16), a17), a18)
        }
    }
}
// ====
// compileViaYul: true
// ----
// f(uint256): 0 -> 171
// f(uint256): 1 -> 342
// f(uint256): 5 -> 1216
