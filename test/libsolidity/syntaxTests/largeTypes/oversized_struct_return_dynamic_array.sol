struct M {
    uint[2**27] a;
}
contract C {
    function f() external pure returns (M[] memory) {}
}
// ----
// TypeError 1534: (85-95): Type too large for memory.
