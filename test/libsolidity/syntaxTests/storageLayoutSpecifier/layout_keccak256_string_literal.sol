contract C layout at uint(keccak256("my.contract.id")) {}

contract CHex layout at uint(keccak256(hex"1234")) {}

contract CEmptyString layout at uint(keccak256("")) {}

contract CEmptyHex layout at uint(keccak256(hex"")) {}

contract CAdd layout at uint(keccak256("my.contract.id")) + 1 {}

contract CSub layout at uint(keccak256("another.contract.id")) - 1 {}
// ----
