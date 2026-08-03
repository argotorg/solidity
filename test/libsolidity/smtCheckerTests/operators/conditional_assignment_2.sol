contract C {
	function f(uint b) public pure {
		require(b < 3);
		uint c = (b > 0) ? b++ : ++b;
		assert(c == 0);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (99-113): CHC: Assertion violation happens here.\nCounterexample:\n\nb = 1\nc = 1\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
