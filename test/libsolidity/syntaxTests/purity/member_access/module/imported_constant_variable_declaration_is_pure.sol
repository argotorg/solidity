==== Source: A.sol ====
uint256 constant GLOBAL_CONST_VAR = 0;
contract C {}
C constant cInstance =  C(address(1));
==== Source: B.sol ====
import * as A from "A.sol";

contract C {
    uint256 constant globalVarConstCopy = A.GLOBAL_CONST_VAR;

    function test() pure private {
        A.GLOBAL_CONST_VAR;
        A.cInstance;
    }
}
// ----
// Warning 6133: (B.sol:148-166): Statement has no effect.
// Warning 6133: (B.sol:176-187): Statement has no effect.
