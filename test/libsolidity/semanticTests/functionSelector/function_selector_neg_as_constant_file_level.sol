// IMPORTANT: The bug was triggered only, when selector is referenced in a constant variable initializer.
// Do not add any code to this test where the constant variable is referenced in non-constant (compile-time) context.
// It would make the test useless.

// File-level constant
bytes4 constant FILE_LEVEL_SELECTOR = ~Base.testFunc.selector;

contract Base {
    function testFunc() public {}

    bytes4 constant public FILE_LEVEL_SELECTOR_COPY = FILE_LEVEL_SELECTOR;
}

// ----
// FILE_LEVEL_SELECTOR_COPY() -> 0xfc85be8300000000000000000000000000000000000000000000000000000000
