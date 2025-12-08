bytes32 constant b = "bytes";
contract A layout at b[1] {}
// ----
// TypeError 1763: (51-55): The base slot of the storage layout must evaluate to an integer (the type is 'bytes1' instead).
