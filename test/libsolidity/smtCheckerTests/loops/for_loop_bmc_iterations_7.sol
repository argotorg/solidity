contract C
{
	uint x;

	function condition() private returns(bool) {
		++x;
		return x < 3;
	}

	function f() public {
		require(x == 0);
		for (; condition();) {
		}
		assert(x == 3);
	}
}
// ====
// BMCLoopIterations: 5
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 2661: (71-74): BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
