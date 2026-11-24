contract C {
    uint public result;

    // mstore() below must survive UnusedStoreEliminator: for flag != 0 the store
    // location `ptr` is reassigned in a branch so that it equals `readAt`.
    // The test only detects the bug when run with --optimize.
    function v3(uint256, uint256) external {
        assembly {
            let flag := calldataload(4)
            let val := calldataload(0x24)
            let ptr := mload(0x40)
            if flag { ptr := add(ptr, 0x20) }
            let readAt := add(ptr, 0x20)
            if flag { ptr := add(ptr, 0x20) }
            mstore(ptr, val)
            sstore(0, mload(readAt))
            stop()
        }
    }
}
// ----
// v3(uint256,uint256): 1, 42 ->
// result() -> 42
// v3(uint256,uint256): 0, 42 ->
// result() -> 0
