type MyUint is uint128;
MyUint constant x = MyUint.wrap(42);
contract C layout at x {}
// ----
// TypeError 6396: (82-83): The base slot of the storage layout must evaluate to a rational number.
