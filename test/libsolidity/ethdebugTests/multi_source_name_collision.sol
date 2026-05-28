==== Source: a.sol ====
contract C {
    function fromA() public pure returns (uint) { return 1; }
}
contract Unique {
    function only() public pure returns (uint) { return 99; }
}
==== Source: b.sol ====
contract C {
    function fromB() public pure returns (uint) { return 2; }
}
// ----
// .resources.compilation.sources | length: 2
// a.sol:C.contract.name: C
// b.sol:C.contract.name: C
// a.sol:C.creation.environment: create
// b.sol:C.creation.environment: create
// Unique.contract.name: Unique
// Unique.creation.environment: create
