struct M {
    uint[2**27] a;
}
contract C {
    function f() public pure {
        M[2] memory m;
        m;
    }
}
// ----
// TypeError 1534: (84-97): Type too large for memory.
