type T1 is uint;
type T2 is uint;

contract C {
	modifier m(T1 x, T2 y) {
		require(T1.unwrap(x) == T2.unwrap(y));
		_;
	}

	function f(uint x, uint y) m(T1.wrap(x), T2.wrap(y)) public pure {
		assert(x == y);
		assert(x != y); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (212-226): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0, 0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
