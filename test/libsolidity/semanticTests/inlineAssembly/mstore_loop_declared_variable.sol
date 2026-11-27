contract C {
    uint public ptr;
    uint public result;

    // mstore() below must survive UnusedStoreEliminator: `p` is declared in the loop body and never
    // reassigned, but has a different value in each iteration. The next iteration reads the word
    // written by mstore() through `sub(p, 32)`.
    // The test only detects the bug when run with --optimize.
    function run() external {
        assembly {
            sstore(0, 0x100)
            let s := 0
            for { let i := 0 } lt(i, 3) { i := add(i, 1) } {
                let p := sload(0)
                s := add(s, mload(sub(p, 32)))
                mstore(p, add(i, 7))
                sstore(0, add(p, 32))
            }
            sstore(1, s)
            stop()
        }
    }
}
// ----
// run() ->
// ptr() -> 0x160
// result() -> 15
