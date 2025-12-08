type MyUint is uint128;
contract C layout at MyUint.wrap(42) {}
// ----
// TypeError 1763: (45-60): The base slot of the storage layout must evaluate to an integer (the type is 'MyUint' instead).
