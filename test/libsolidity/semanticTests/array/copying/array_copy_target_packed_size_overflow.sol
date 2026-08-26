contract C {
    uint128[] data;

    function corruptLength() public {
        uint256 slot;
        assembly { slot := data.slot }
        bytes32 dataArea = keccak256(abi.encode(slot));
        assembly {
            sstore(dataArea, not(0))
            sstore(slot, not(0))
        }
    }

    function assignSmaller() public {
        uint128[] memory m = new uint128[](1);
        m[0] = 7;
        data = m;
    }

    function firstDataSlot() public view returns (bytes32 result) {
        uint256 slot;
        assembly { slot := data.slot }
        bytes32 dataArea = keccak256(abi.encode(slot));
        assembly { result := sload(dataArea) }
    }
}
// ----
// corruptLength() ->
// assignSmaller() -> FAILURE, hex"4e487b71", 0x11
// firstDataSlot() -> -1
