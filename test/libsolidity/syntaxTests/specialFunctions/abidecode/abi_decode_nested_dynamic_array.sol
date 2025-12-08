pragma abicoder v1;
contract C {
    function f() public pure {
        abi.decode("1234", (uint[][3]));
    }
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 9611: (92-101): Decoding type uint256[][3] memory not supported.
