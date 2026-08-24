contract C {
    uint constant ONE = 1;
    uint constant LEFT_SHIFT = ONE << 0x100000000;
    uint constant RIGHT_SHIFT = ONE >> 0x100000000;
    uint[LEFT_SHIFT + 1] left;
    uint[RIGHT_SHIFT + 1] right;

    function testEquivalence() public view returns (bool) {
        uint leftRuntime = ONE << 0x100000000;
        uint rightRuntime = ONE >> 0x100000000;

        return
            leftRuntime == LEFT_SHIFT &&
            rightRuntime == RIGHT_SHIFT &&
            left.length == 1 &&
            right.length == 1;
    }
}
// ----
// testEquivalence() -> true
