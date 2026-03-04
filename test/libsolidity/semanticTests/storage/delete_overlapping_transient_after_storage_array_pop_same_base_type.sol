contract C {
    uint256[] arr;
    uint256 transient t;

    function pushArr() external {
        arr.push(1);
    }

    function setAndClear() external {
        t = 2;
        delete t;
        assert(t == 0);
        arr.pop();
    }

    // Get value at index 0, which should have been cleared after arr.pop()
    function getArr() external returns (uint256 value) {
        assembly {
            mstore(0, arr.slot)
            value := sload(keccak256(0x00, 0x20))
        }
    }
}
// ====
// EVMVersion: >=cancun
// ----
// pushArr() ->
// getArr() -> 1
// setAndClear() ->
// getArr() -> 0
