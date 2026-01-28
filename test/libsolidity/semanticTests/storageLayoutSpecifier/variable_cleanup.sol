contract C layout at 42 {
    uint8 x;
    int8 y;
    bytes2 b;
    // Note the return types are larger than the state variable ones
    function f(uint _x, int _y, bytes3 _b) public returns (uint16, int32, bytes32) {
        x = uint8(_x);
        y = int8(_y);
        b = bytes2(_b);
        require(b == "ab");
        return (x, y, b);
    }
}
// ----
// f(uint256,int256,bytes3): 0x0100, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f, "abc" -> 0x00, 0x7f, "ab"
