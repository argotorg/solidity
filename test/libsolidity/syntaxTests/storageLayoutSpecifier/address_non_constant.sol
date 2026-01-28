contract A {}

contract C layout at address(new A()) {}
contract D layout at uint160(address(this)) {}
// ----
// TypeError 1139: (36-52): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (77-99): The base slot of the storage layout must be a compile-time constant expression.
