contract A {}
contract B is A {}
contract C is B layout at 42 {}
contract D is C {}
// ----
// TypeError 8894: (79-80): Cannot inherit from a contract with a custom storage layout.
