pragma abicoder v1;
contract C {
    function test() public pure {
        abi.encode([new uint[](5), new uint[](7)]);
    }
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 2056: (86-116): This type cannot be encoded.
