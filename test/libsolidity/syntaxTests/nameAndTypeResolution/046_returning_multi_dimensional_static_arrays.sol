pragma abicoder v1;
contract C {
    function f() public pure returns (uint[][2] memory) {}
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 4957: (71-87): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
