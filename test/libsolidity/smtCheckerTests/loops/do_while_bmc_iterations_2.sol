contract C
{
	function f() public pure {
		uint x;
		do {
			++x;
			{
				++x;
				++x;
			}
		} while (x < 3);
		assert(x == 3);
	}
}
// ====
// BMCLoopIterations: 3
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
