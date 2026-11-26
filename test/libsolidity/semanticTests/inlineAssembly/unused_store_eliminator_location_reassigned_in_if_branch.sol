contract C {
    uint public result;

    // mstore() below must survive UnusedStoreEliminator: for an even argument the
    // store location `b` is 32, which equals the read location `a`.
    // The test only detects the bug when run with --optimize.
    function f(uint256) external {
        assembly {
            let v := 32
            if true {
                if and(calldataload(4), 1) {
                    v := 32
                }
            }
            let a1 := v
            let a := a1
            if true {
                v := 0
                if and(calldataload(4), 1) {
                    v := 32
                }
            }
            let b := add(v, 32)
            let newValue := 7
            mstore(b, newValue)
            let res := mload(a)
            sstore(0, res)
            stop()
        }
    }
}
// ----
// f(uint256): 0 ->
// result() -> 7
// f(uint256): 1 ->
// result() -> 0
