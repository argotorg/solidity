==== Source: s1.sol ====


uint constant a = 89;

function fre() pure returns (uint) {
	return a;
}

==== Source: s2.sol ====

import {a as b, fre} from "s1.sol";
import "s1.sol" as M;

uint256 constant a = 13;

contract C {
	function f() internal pure returns (uint, uint, uint, uint) {
		return (a, fre(), M.a, b);
	}
	function p() public pure {
		(uint x, uint y, uint z, uint t) = f();
		assert(x == 13); // should hold
		assert(y == 89); // should hold
		assert(z == 89); // should hold
		assert(t == 89); // should hold
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
