contract C {
	function f(bytes calldata data) external pure returns (uint256[] memory) {
		return abi.decode(data, (uint256[]));
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
