// IMPORTANT: The bug was triggered only, when selector is referenced in a constant variable initializer.
// Do not add any code to this test where the constant variable is referenced in non-constant (compile-time) context.
// It would make the test useless.

contract B {
    function g() public {}
}

contract UnrelatedContract {
    bytes4 public constant UNRELATED_SELECTOR = B.g.selector;
}
// ----
// UNRELATED_SELECTOR() -> 0xe2179b8e00000000000000000000000000000000000000000000000000000000
