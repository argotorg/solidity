contract A {}
contract C layout at A(address(0x1234)) {}
// ----
// TypeError 6396: (35-53): The base slot of the storage layout must evaluate to a rational number.
