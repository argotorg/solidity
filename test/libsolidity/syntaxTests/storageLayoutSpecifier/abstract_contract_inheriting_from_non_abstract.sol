contract A layout at 0x1234 {}
abstract contract C is A { }
// ----
// TypeError 8894: (54-55): Cannot inherit from a contract with a custom storage layout.
