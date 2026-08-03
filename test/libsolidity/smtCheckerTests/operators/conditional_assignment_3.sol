contract C {
	function f(uint a, uint b) public pure {
		require(a < 10);
		require(b <= a);

		uint c = (b > 4) ? a++ : b++;
		assert(c > a);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (128-141): CHC: Assertion violation happens here.\nCounterexample:\n\na = 6\nb = 5\nc = 5\n\nTransaction trace:\nC.constructor()\nC.f(5, 5)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
