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
// .compilation.sources | length: 2
// .compilation.sources[0].id: 0
// .compilation.sources[0].path: a.sol
// .compilation.sources[1].id: 1
// .compilation.sources[1].path: b.sol
// .resources.compilation.sources | length: 2
// .resources.compilation.sources[0].id: 0
// .resources.compilation.sources[0].path: a.sol
// .resources.compilation.sources[1].id: 1
// .resources.compilation.sources[1].path: b.sol
// a.sol:C.contract.name: C
// b.sol:C.contract.name: C
// a.sol:C.creation.environment: create
// b.sol:C.creation.environment: create
// Unique.contract.name: Unique
// Unique.creation.environment: create
