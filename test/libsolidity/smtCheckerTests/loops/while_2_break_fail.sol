contract C
{
	function f(uint x) public pure {
		while (x == 0) {
			++x;
			break;
			++x;
		}
		assert(x == 2);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTSolvers: z3
// ----
// Warning 5740: (87-90): Unreachable code.
// Warning 6328: (98-112): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 3\n\nTransaction trace:\nC.constructor()\nC.f(3)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
