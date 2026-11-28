// The size of S is 2**31 + (2**31 - 32) == 2**32 - 32 bytes in memory and calldata.
struct M {
    uint[2**26] a;
}
struct N {
    uint[2**26 - 1] a;
}
struct S {
    M m;
    N n;
}
contract C {
    function f() public pure {
        S memory s;
        s;
    }
    function g(S calldata) external pure {}
}
