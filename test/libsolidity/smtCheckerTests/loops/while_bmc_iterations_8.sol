contract C
{
	uint256[] y;

	function f() public view {
		uint256 x = 0;
		while (x < y.length) {
			x = 1;
		}
		// tests that constant condition warning is not reported
		require(x != 0);
	}
}
// ====
// BMCLoopIterations: 1
// SMTEngine: bmc
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
