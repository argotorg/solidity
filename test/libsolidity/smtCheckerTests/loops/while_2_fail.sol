contract C {
	function f(uint x) public pure {
		x = 2;
		while (x > 1) {
			if (x > 10)
				x = 2;
			else
				x = 10;
		}
		assert(x == 2);
	}
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
