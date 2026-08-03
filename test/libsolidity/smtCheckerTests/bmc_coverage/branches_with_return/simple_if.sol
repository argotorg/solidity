contract C {
	function test(uint256 a, uint256 b) public pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		return b / a; // This division is safe because of the early return in if-block.
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
