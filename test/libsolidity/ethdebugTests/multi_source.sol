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
// .resources.compilation.sources | length: 2
// Lib.contract.name: Lib
// Main.contract.name: Main
// Lib.creation.environment: create
// Main.creation.environment: create
