contract C {
	function f() public pure {
		uint x;
		do {
			break;
		} while (++x < 2);
        // loop condition is not executed after break
		assert(x == 0);
	}
}
// ====
// BMCLoopIterations: 3
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 5740: (79-86): Unreachable code.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
