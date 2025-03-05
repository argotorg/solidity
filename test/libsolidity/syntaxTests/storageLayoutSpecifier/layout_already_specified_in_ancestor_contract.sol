contract A layout at 0x1234 {}

contract B is A {}

contract C is B layout at 0xABCD {}
// ----
// TypeError 8894: (46-47): Cannot inherit from a contract with a custom storage layout.
