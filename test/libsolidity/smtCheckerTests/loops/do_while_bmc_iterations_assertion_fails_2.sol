contract C {
	function f() public pure {
		uint x;
		do {
			++x;
			break;
		} while (x < 3);
		assert(x == 0);
		assert(x == 1);
	}
}
// ====
// BMCLoopIterations: 2
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 5740: (87-92): Unreachable code.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (97-111): BMC: Assertion violation happens here.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
