contract C layout at uint64(bytes8(bytes.concat("ABCD", "EFGH"))) {}
// ----
// TypeError 1505: (21-65): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
