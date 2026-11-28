struct M {
    uint[2**27] a;
}
contract C {
    function f() public pure {
        M[] memory m;
        m;
    }
}
// ----
// TypeError 1534: (84-96): Type too large for memory.
