contract A layout at addmod(1, 2, 3) {}
contract B layout at mulmod(3, 2, 1) {}
// ----
// TypeError 6396: (21-36): The base slot of the storage layout must evaluate to a rational number.
// TypeError 6396: (61-76): The base slot of the storage layout must evaluate to a rational number.
