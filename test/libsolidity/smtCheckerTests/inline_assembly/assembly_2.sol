contract C {
	function f() public pure returns (bool) {
		bool b;
		int x = 42;
		assembly { b := 1 }
		assert(x == 42); // should hold
		assert(b); // should hold, but fails due to overapproximation
		return b;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 7737: (82-101): Inline assembly may cause SMTChecker to produce spurious warnings (false positives).
// Warning 6328: (138-147): CHC: Assertion violation happens here.\nCounterexample:\n\n = false\nb = false\nx = 42\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
