pragma abicoder v1;
contract C {
    struct S { uint x; }
    S s;
    struct T { uint y; }
    T t;
    function f() public view {
        abi.encode(s, t);
    }
    function g() public view {
        abi.encodePacked(s, t);
    }
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 2056: (151-152): This type cannot be encoded.
// TypeError 2056: (154-155): This type cannot be encoded.
// TypeError 9578: (220-221): Type not supported in packed mode.
// TypeError 9578: (223-224): Type not supported in packed mode.
