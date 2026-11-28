// The size of S is 2**31 + (2**26 - 1) * 32 == 2**32 - 32 bytes in memory and calldata.
struct S {
    uint[2**26] a;
    uint[2**26 - 1] b;
}
contract C {
    function f() public pure {
        S memory s;
        s;
    }
    function g(S calldata) external pure {}
}
