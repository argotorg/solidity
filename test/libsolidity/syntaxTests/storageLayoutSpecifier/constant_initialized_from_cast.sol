uint constant x = uint(42);
contract C layout at x {}
// ----
// TypeError 1505: (49-50): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
