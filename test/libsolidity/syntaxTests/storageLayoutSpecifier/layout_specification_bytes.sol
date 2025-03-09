bytes32 constant b = "bytes";
contract A layout at b[1] {}
// ----
// TypeError 6396: (51-55): The base slot of the storage layout must evaluate to a rational number.
