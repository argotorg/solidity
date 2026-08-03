contract C
{
	function f(C c, C d) public pure {
		assert(c == d);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 9170: (58-64): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Warning 6328: (51-65): CHC: Assertion violation happens here.\nCounterexample:\n\nc = 0\nd = 1\n\nTransaction trace:\nC.constructor()\nC.f(0, 1)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
