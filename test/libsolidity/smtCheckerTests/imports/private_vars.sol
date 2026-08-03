==== Source: ERC20.sol ====
contract ERC20 {
    uint256 private a;
    function f() internal virtual {
        a = 2;
    }
}
==== Source: Token.sol ====
import "ERC20.sol";
contract Token is ERC20 {
    constructor() {
      f();
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
