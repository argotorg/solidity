contract C {
	function f(uint x) public pure {
		require(x == 0);
		uint y;
		do {
			++y;
			if (y == 2)
			    x = 3;
		} while (y < 3);
		// nothing is reported because loop condition is true after unrolling the loop one time
		assert(x == 4);
	}
}
// ====
// BMCLoopIterations: 1
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
