contract C
{
	function f(uint x) public pure {
		require(x < 100);
		do {
			x = x + 1;
		} while (x < 10);
		assert(x < 14);
	}
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Warning 6328: (110-124): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 14\n\nTransaction trace:\nC.constructor()\nC.f(13)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
