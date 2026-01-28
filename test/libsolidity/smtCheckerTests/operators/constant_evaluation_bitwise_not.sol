contract C {
    uint256 constant largeConstant = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    function test() public pure returns (uint256) {
        return ~largeConstant;
    }
}
// ====
// SMTEngine: chc
// ----
