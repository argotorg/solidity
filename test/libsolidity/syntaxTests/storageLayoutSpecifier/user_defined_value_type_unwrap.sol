type MyUint is uint128;
MyUint constant x = MyUint.wrap(42);
contract C layout at MyUint.unwrap(x) {}
// ----
// TypeError 6396: (82-98): The base slot of the storage layout must evaluate to a rational number.
