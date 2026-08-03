contract C {
	function f(uint z) public pure {
		uint x = 0;
		require(z == 0);
		while (x < 2) {
			uint y = 0;
			while (y < 2) {
				if (y > 0)
					break;
				++z;
				++y;
			}
			++x;
		}
		assert(z == 2);
	}
}
// ====
// BMCLoopIterations: 3
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
