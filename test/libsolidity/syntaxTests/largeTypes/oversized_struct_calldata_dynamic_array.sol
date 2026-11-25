struct M {
    uint[2**27] a;
}
contract C {
    function f(M[] calldata) external pure {}
}
// ----
// TypeError 1534: (60-72): Type too large for calldata.
