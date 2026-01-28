contract C layout at abi.decode(abi.encode(42), (uint)) {}
// ----
// TypeError 1505: (21-55): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
