contract C
{
	function f(uint x) public pure {
		require(x == 0);
		for (uint i = 0; i < 3; ++i) {
			if (x > 1) {
				x = 10;
				continue;
			}
			if (x > 0) {
				x = 11;
				continue;
			}
			++x;
		}
		assert(x == 10);
	}
}
// ====
// BMCLoopIterations: 4
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
