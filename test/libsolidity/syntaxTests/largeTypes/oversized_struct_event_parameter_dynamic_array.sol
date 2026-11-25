struct M {
    uint[2**27] a;
}
contract C {
    event E(M[] m);
    function f() public {
        emit E(new M[](0));
    }
}
// ----
// TypeError 1534: (57-62): Type too large for memory.
