contract C
{
	function f() public pure {
		uint x = 0;
		while (x == 0) {
			++x;
			break;
			++x;
		}
		assert(x == 1);
	}
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Warning 5740: (95-98): Unreachable code.
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
