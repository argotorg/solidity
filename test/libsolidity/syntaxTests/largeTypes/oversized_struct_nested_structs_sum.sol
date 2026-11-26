// Each nested struct T takes 2**31 bytes, but S takes 2**32 bytes in memory and calldata.
struct T {
    uint[2**26] a;
}
struct S {
    T t1;
    T t2;
}
contract C {
    function f() public pure {
        S memory s;
        s;
    }
    function g(S calldata) external pure {}
}
// ----
// TypeError 1534: (208-218): Type too large for memory.
// TypeError 1534: (252-262): Type too large for calldata.
