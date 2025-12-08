pragma abicoder v1;
contract c {
    event E(uint[][]);
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 3061: (45-53): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
