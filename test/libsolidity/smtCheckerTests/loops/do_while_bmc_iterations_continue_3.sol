contract C {
	function f() public pure {
		uint x = 0;
		uint y = 0;
		do {
			++x;
			if (x > 0) {
				y = 1;
				continue;
			}
			if (x > 0) {
				y = 2;
				continue;
			}
		} while (x < 3);
		assert(y == 1);
	}
}
// ====
// BMCLoopIterations: 4
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
