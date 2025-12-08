contract A layout at [1, 2, 3][0] {}
contract B layout at 255 + [1, 2, 3][0] {}
// ----
// TypeError 1505: (21-33): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
// TypeError 1505: (58-76): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
