pragma abicoder v1;
contract C {
    function f() public pure {
        abi.encodePacked([new uint[](5), new uint[](7)]);
    }
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 9578: (89-119): Type not supported in packed mode.
