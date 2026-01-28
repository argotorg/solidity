contract A layout at 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF + 1 {}
contract B layout at 2**256 {}
// ----
// TypeError 6753: (21-91): The base slot of the storage layout evaluates to 2**256, which is outside the range of type uint256.
// TypeError 6753: (116-122): The base slot of the storage layout evaluates to 2**256, which is outside the range of type uint256.
