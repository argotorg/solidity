contract C
{
	function f(uint x) public pure {
		require(x == 0);
		for (uint i = 0; i < 2; ++i) {
			for (uint j = 0; j < 2; ++j) {
				x = x + 1;
				break;
			}
			break;
		}
		assert(x == 1);
	}
}
// ====
// BMCLoopIterations: 3
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 5740: (92-95): Unreachable code.
// Warning 5740: (126-129): Unreachable code.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
