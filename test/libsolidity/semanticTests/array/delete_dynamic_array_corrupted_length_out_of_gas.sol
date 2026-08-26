contract C {
    uint256[] data;

    function corruptLength() public {
        uint256 slot;
        assembly { slot := data.slot }
        assembly { sstore(slot, not(0)) }
    }

    function clear() public {
        delete data;
    }

    function length() public view returns (uint256) {
        return data.length;
    }
}
// ----
// corruptLength() ->
// clear() -> FAILURE
// length() -> -1
