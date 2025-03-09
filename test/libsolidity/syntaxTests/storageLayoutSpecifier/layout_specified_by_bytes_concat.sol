contract C layout at uint64(bytes8(bytes.concat("ABCD", "EFGH"))) {}
// ----
// TypeError 1139: (21-65): The base slot of the storage layout must be a compile-time constant expression.
