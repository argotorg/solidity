contract C
{
	uint x;
	uint y;

	function condition() private returns(bool) {
		x = (x + 1) % 2;
		return (x == 1);
	}

	function f() public {
		require(x == 0);
		require(y == 0);
		do {
			++y;
		} while (condition());
		assert(y == 2);
	}
}
// ====
// BMCLoopIterations: 5
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 2661: (85-90): BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
// Info 6002: BMC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
