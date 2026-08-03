contract C {
	function fromSlice(bytes calldata c) external pure returns (bytes32) {
		return bytes32(c[0:33]);
	}
}
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
