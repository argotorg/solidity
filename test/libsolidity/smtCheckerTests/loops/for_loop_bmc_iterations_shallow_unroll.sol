contract C
{
	function f() public pure {
		uint x = 0;
		for (uint i = 0; i < 2; ++i) {
			++x;
		}
		// nothing is reported because loop condition is still true after BMCLoopIterations
		assert(x == 3);
	}
}
// ====
// BMCLoopIterations: 1
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
