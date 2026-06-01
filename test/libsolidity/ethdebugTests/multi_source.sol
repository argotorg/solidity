==== Source: lib.sol ====
contract Lib {
    function helper() public pure returns (uint) { return 1; }
}
==== Source: main.sol ====
import "lib.sol";
contract Main {
    function f() public pure returns (uint) { return 42; }
}
// ----
// .compilation.sources | length: 2
// .compilation.sources[0].id: 0
// .compilation.sources[0].path: lib.sol
// .compilation.sources[1].id: 1
// .compilation.sources[1].path: main.sol
// .resources.compilation.sources | length: 2
// .resources.compilation.sources[0].id: 0
// .resources.compilation.sources[0].path: lib.sol
// .resources.compilation.sources[1].id: 1
// .resources.compilation.sources[1].path: main.sol
// Lib.contract.name: Lib
// Main.contract.name: Main
// Lib.creation.environment: create
// Main.creation.environment: create
