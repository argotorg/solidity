contract C
{
	function f(uint x) public pure {
		require(x < 100);
		do {
			x = x + 1;
		} while (x < 1000);
		assert(x > 0);
	}
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
