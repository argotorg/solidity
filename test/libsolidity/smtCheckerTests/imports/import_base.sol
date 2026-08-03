==== Source: base ====
contract Base {
	uint x;
	address a;
	function f() internal returns (uint) {
		a = address(this);
		++x;
		return 2;
	}
}
==== Source: der ====
import "base";
contract Der is Base {
	function g(uint y) public {
		require(x < 10); // added to restrict the search space and avoid non-determinism in Spacer
		x += f();
		assert(y > x);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6328: (der:174-187): CHC: Assertion violation happens here.\nCounterexample:\nx = 3, a = 0x0\ny = 0\n\nTransaction trace:\nDer.constructor()\nState: x = 0, a = 0x0\nDer.g(0)\n    Base.f() -- internal call
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
