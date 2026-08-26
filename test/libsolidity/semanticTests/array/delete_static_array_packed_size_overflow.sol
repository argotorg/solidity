contract C {
    uint8[2**256 - 1] data;

    function set() public {
        data[0] = 42;
    }

    function clear() public {
        delete data;
    }

    function first() public view returns (uint8) {
        return data[0];
    }
}
// ----
// set() ->
// clear() -> FAILURE, hex"4e487b71", 0x11
// first() -> 42
