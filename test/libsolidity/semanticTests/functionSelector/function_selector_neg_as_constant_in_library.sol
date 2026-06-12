// IMPORTANT: The bug was triggered only, when selector is referenced in a constant variable initializer.
// Do not add any code to this test where the constant variable is referenced in non-constant (compile-time) context.
// It would make the test useless.

library L {
    function g() public {}
    bytes4 public constant LIB_SELECTOR = ~L.g.selector;
}
// ----
// LIB_SELECTOR() -> 0x1de8647100000000000000000000000000000000000000000000000000000000
