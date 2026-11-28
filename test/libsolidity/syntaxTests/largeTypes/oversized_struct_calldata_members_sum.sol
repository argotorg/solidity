// Each member fits in calldata on its own (2**31 bytes), but the struct takes 2**32 bytes.
struct S {
    uint[2**26] a;
    uint[2**26] b;
}
contract C {
    function f(S calldata) external pure {}
}
// ----
// TypeError 1534: (171-181): Type too large for calldata.
