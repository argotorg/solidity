type MyUint is uint128;
MyUint constant x = MyUint.wrap(42);
contract C layout at x {}
// ----
// TypeError 1763: (82-83): The base slot of the storage layout must evaluate to an integer (the type is 'MyUint' instead).
