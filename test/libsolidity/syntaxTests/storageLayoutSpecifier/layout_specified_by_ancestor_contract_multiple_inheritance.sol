contract A layout at 1 {}
contract B is A layout at 2 {}

contract C1 is B {}
contract C2 is A, B {}
contract C3 is B {}

contract D1 is C1 {}
contract D2 is C2 {}
contract D3 is C3 {}
// ----
// TypeError 8894: (40-41): Cannot inherit from a contract with a custom storage layout.
// TypeError 8894: (73-74): Cannot inherit from a contract with a custom storage layout.
// TypeError 8894: (93-94): Cannot inherit from a contract with a custom storage layout.
// TypeError 8894: (96-97): Cannot inherit from a contract with a custom storage layout.
// TypeError 8894: (116-117): Cannot inherit from a contract with a custom storage layout.
