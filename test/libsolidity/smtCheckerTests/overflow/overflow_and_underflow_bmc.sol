contract C {
	function f(int x, int y) public pure returns (int) {
		require(x == 0);
		require(y == 0);
		return x + y;
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
