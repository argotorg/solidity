contract A {}
contract B is A {}
contract C {}
contract D is A, C layout at 2**256 - 2**64 {}
// ----
// Warning 3495: (66-90): This contract is very close to the end of storage. This limits its future upgradability.
