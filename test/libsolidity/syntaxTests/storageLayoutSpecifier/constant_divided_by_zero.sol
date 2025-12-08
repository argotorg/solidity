uint constant N = 100;
contract C layout at N / 0 {}
// ----
// TypeError 1505: (44-49): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
