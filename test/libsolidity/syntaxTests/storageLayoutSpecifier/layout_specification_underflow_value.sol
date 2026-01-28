contract A layout at 0 - 1 {}
contract B layout at 2**8 - 2**16 {}
// ----
// TypeError 6753: (21-26): The base slot of the storage layout evaluates to -1, which is outside the range of type uint256.
// TypeError 6753: (51-63): The base slot of the storage layout evaluates to -65280, which is outside the range of type uint256.
