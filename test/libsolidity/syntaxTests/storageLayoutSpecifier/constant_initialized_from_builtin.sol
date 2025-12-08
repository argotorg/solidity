uint constant x = addmod(10, 2, 8);
uint constant y = mulmod(10, 2, 8);
contract C layout at x {}
contract D layout at y {}
// ----
// TypeError 1505: (93-94): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
// TypeError 1505: (119-120): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
