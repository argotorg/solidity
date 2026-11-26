// The total size of N is 2**31 + 2**31 == 2**32.
struct M {
    uint[2**26] a;
}
struct N {
    M a;
    M b;
}
contract C {
    function f() public pure {
        N memory n;
        n;
    }
}
// ----
// TypeError 1534: (165-175): Type too large for memory.
