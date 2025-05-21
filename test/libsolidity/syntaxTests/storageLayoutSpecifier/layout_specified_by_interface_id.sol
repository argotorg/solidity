interface I {}

contract C layout at uint(bytes32(type(I).interfaceId)) { }
// ----
// TypeError 6396: (37-71): The base slot of the storage layout must evaluate to a rational number.
