contract C layout at 42 {
    uint8 x;
    int8 y;
    bytes2 b;
    // Note the return types are larger than the state variable ones
    function f() public returns (uint16, int32, bytes16) {
        uint32 z = 0;
        z = z | 0x10;
        z = z | 0x7f00;
        z = z | 0x61620000;

        assembly {
            sstore(x.slot, z)
        }
        require(b == "ab");
        return (x, y, b);
    }
}
// ----
// f() -> 0x10, 127, "ab"
