interface I {}

contract C layout at uint(bytes32(type(I).interfaceId)) { }
// ----
// TypeError 1505: (37-71): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
