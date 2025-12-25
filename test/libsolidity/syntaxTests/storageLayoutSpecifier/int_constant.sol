int constant x = -42;
int constant y = 64;
contract C layout at x {}
contract D layout at y {}
// ----
// TypeError 6753: (64-65): The base slot of the storage layout evaluates to -42, which is outside the range of type uint256.
// TypeError 1481: (90-91): Base slot expression of type 'int256' is not convertible to uint256.
