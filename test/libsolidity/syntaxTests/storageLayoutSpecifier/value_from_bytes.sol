bytes32 constant b = "Solidity";
contract C layout at uint8(b[1]) {}
// ----
// TypeError 6396: (54-65): The base slot of the storage layout must evaluate to a rational number.
