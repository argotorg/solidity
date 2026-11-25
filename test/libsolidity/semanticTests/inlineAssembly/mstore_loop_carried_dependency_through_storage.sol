contract C {
    uint public ptr;
    uint public result;

    // mstore() below must survive UnusedStoreEliminator: the word written in one iteration
    // is read back in the next one, with the pointer carried through storage.
    // The test only detects the bug when run with --optimize.
    function run() external {
        assembly {
            sstore(0, 128)
            for { let i := 0 } lt(i, 2) { i := add(i, 1) } {
                let v := sload(0)
                let w := add(v, 32)
                mstore(v, 0xAA)
                sstore(0, sub(v, 32))
                sstore(1, mload(w))
            }
            stop()
        }
    }
}
// ----
// run() ->
// ptr() -> 64
// result() -> 0xaa
