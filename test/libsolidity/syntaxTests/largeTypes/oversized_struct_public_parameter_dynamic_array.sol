struct M {
    uint[2**27] a;
}
contract C {
    function f(M[] memory) public pure {}
}
// ----
// TypeError 1534: (60-70): Type too large for memory.
