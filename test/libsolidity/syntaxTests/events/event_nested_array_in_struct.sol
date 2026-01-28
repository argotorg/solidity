pragma abicoder v1;
contract c {
	struct S { uint x; uint[][] arr; }
    event E(S);
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 3061: (81-82): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
