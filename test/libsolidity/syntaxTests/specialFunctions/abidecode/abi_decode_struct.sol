pragma abicoder v1;
struct S {
    uint x;
}

contract C {
    function f() public pure {
        abi.decode("1234", (S));
    }
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 9611: (118-119): Decoding type struct S memory not supported.
