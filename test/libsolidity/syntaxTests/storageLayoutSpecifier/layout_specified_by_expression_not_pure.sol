function f(uint x) returns (uint) { return x + 1; }
contract A layout at f(2) {}
// ----
// TypeError 1139: (73-77): The base slot of the storage layout must be a compile-time constant expression.
