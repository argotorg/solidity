==== ExternalSource: _prbmath/PRBMathCommon.sol ====
==== ExternalSource: _prbmath/PRBMathUD60x18.sol ====
==== Source: prbmath.sol ====
import "_prbmath/PRBMathUD60x18.sol";

// Regression test for SwitchSplitter's handling of switches inside creation code:
// PRBMathUD60x18.log10 contains a 39-case switch, only ever called here from the
// constructor, so its dispatch is compiled as part of the creation code rather than
// the runtime code.
contract test {
    using PRBMathUD60x18 for uint256;

    uint256 public immutable result;

    constructor(uint256 x) {
        result = x.log10();
    }
}
// ----
// constructor(): 1000000000000000000000
// gas irOptimized: 108615
// gas irOptimized code: 18600
// gas legacy: 118230
// gas legacy code: 29800
// gas legacyOptimized: 109471
// gas legacyOptimized code: 19600
// gas ssaCFGOptimized: 105833
// gas ssaCFGOptimized code: 17200
// result() -> 3000000000000000000
