contract A layout at 42 {}
contract B is A {}
contract C is B {}
contract D is C {}
// ----
// TypeError 8894: (41-42): Cannot inherit from a contract with a custom storage layout.
