contract C {
	function f() public pure {
		uint x = 0;
		int y = 0;
		for (; x < 3 || y == 1; ++x) {
			if (x >= 3)
				y = 1;
		}
		// BMC loop iteration setting is just enough to leave the loop
		assert(x == 3);
		assert(y == 1); // should fail
		assert(y == 0);
	}
}
// ====
// BMCLoopIterations: 3
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (216-230): BMC: Assertion violation happens here.
// Info 6002: BMC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
