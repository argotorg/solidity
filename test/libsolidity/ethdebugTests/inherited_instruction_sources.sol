==== Source: A.sol ====
import "B.sol";
contract Main is Base {
    constructor() payable { set(); }
    fallback() external payable { set(); }
}
==== Source: B.sol ====
contract Base {
    function set() internal {
        assembly { sstore(0, 1) }
    }
}
// ----
// .compilation.sources[0].path: A.sol
// .compilation.sources[1].path: B.sol
// Main.contract.definition.source.id: 0
// Main.creation.instructions[0].context.code.source.id: 0
// Main.creation.instructions[32].context.code.source.id: 1
// Main.runtime.instructions[0].context.code.source.id: 0
// Main.runtime.instructions[17].context.code.source.id: 1
