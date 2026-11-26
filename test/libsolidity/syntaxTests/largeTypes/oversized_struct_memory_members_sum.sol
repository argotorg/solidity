// Each member fits in memory on its own (2**31 bytes), but the struct takes 2**32 bytes.
struct S {
    uint[2**26] a;
    uint[2**26] b;
}
contract C {
    function f() public pure {
        S memory s;
        s;
    }
}
// ----
// TypeError 1534: (193-203): Type too large for memory.
