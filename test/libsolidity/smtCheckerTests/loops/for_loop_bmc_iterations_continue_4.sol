contract C
{
	function f() public pure {
		uint x;
		for (; x < 2; ++x) {
			if (x > 1) {
				x = 10;
				continue;
			}
			if (x > 0) {
				x = 11;
				continue;
			}
		}
		// x > 0 branch triggers x = 11 and continue triggers ++x loop expression
		assert(x == 12);
	}
}
// ====
// BMCLoopIterations: 4
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
