contract C layout at uint(keccak256(bytes.concat("ABCD"))) {}
// ----
// TypeError 1139: (21-58): The base slot of the storage layout must be a compile-time constant expression.
