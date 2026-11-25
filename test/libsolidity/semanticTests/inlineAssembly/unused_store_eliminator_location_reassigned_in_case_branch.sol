contract C {
    uint public result;

    // mstore() below must survive UnusedStoreEliminator: for selector == 0 the store
    // location `v` is reassigned in a switch case so that it equals `a`.
    // The test only detects the bug when run with --optimize.
    function f(uint256) external {
        assembly {
            let v := mload(0x40)
            switch calldataload(4)
            case 0 {
                v := add(v, 0x20)
            }
            let a1 := add(v, 0x20)
            let a := a1
            switch calldataload(4)
            case 0 {
                v := add(v, 0x20)
            }
            let y := 7
            mstore(v, y)
            sstore(0, mload(a))
            stop()
        }
    }
}
// ----
// f(uint256): 0 ->
// result() -> 7
// f(uint256): 1 ->
// result() -> 0
