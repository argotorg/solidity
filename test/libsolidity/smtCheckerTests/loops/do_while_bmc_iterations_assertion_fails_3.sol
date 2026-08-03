contract C {
	function f() public pure {
		uint x;
		do {
			++x;
			continue;
		} while (x < 2);
		assert(x == 0);
	}
}
// ====
// BMCLoopIterations: 2
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (100-114): BMC: Assertion violation happens here.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
