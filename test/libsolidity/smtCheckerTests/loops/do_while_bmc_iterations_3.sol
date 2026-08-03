contract C
{
	function f() public pure {
		uint x;
		do {
			if (x >= 2)
				++x;
			++x;
		} while (x < 3);
		assert(x == 4);
	}
}
// ====
// BMCLoopIterations: 5
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
