contract C
{
	function f(uint x) public pure {
		require(x == 0);
		while (x < 2) {
			++x;
		}
		assert(x == 3);
	}
}
// ====
// BMCLoopIterations: 3
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (98-112): BMC: Assertion violation happens here.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
