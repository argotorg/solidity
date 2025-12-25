pragma abicoder v1;
struct S {uint a;}
contract C {
    error MyError(S);
}
// ----
// Warning 9511: (0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 3061: (70-71): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
