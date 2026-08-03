contract C {
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0);
		uint256 c = a / b;
		return c;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
