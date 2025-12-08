bytes32 constant CONST1 = "12345";
contract A layout at CONST1 {}
contract C layout at CONST1[1] {}
// ----
// TypeError 1763: (56-62): The base slot of the storage layout must evaluate to an integer (the type is 'bytes32' instead).
// TypeError 1763: (87-96): The base slot of the storage layout must evaluate to an integer (the type is 'bytes1' instead).
