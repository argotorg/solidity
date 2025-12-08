contract C layout at uint(keccak256(bytes.concat("ABCD"))) {}
// ----
// TypeError 1505: (21-58): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
