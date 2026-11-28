// The total size of N is 2**31 + 2**31 == 2**32.
struct M {
    uint[2**26] a;
}
struct N {
    M a;
    M b;
}
contract C {
    function f(N calldata) external pure {}
}
// ----
// TypeError 1534: (141-151): Type too large for calldata.
