contract C
{
	function f() public pure {
		uint x;
		for (uint i = 0; i < 3; ++i) {
			if (i > 1) {
				x = 1;
				break;
			}
			if (i > 1) {
				x = 2;
				break;
			}
		}
		assert(x == 1);
	}
}
// ====
// BMCLoopIterations: 4
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
