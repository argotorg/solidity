// The total size of M[2] is 2 * 2**31 == 2**32.
struct M {
    uint[2**26] a;
}
contract C {
    function f() public pure {
        M[2] memory m;
        m;
    }
}
// ----
// TypeError 1534: (133-146): Type too large for memory.
