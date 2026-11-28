// The memory size of M is (2**27 - 1) * 32 == 2**32 - 32.
struct M {
    uint[2**27 - 1] a;
}
contract C {
    function f(M[] calldata) external pure {}
    function g() public pure {
        M[] memory m;
        m;
    }
}
// ----
