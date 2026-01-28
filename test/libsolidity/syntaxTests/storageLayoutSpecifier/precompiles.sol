contract A layout at addmod(1, 2, 3) {}
contract B layout at mulmod(3, 2, 1) {}
// ----
// TypeError 1505: (21-36): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
// TypeError 1505: (61-76): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
