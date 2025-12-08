pragma abicoder v1;
contract C {
	struct s { uint a; uint b; }
    function f() pure public {
        abi.decode("", (s));
    }
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 9611: (118-119): Decoding type struct C.s memory not supported.
