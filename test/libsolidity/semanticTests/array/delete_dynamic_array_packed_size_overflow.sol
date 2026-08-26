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

    function clear() public {
        delete data;
    }

    function length() public view returns (uint256) {
        return data.length;
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
// clear() -> FAILURE, hex"4e487b71", 0x11
// length() -> -1
// firstDataSlot() -> -1
