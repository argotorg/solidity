contract C {
	function f(bytes calldata data) external pure returns (bytes memory) {
		return abi.encode(bytes(data[:32]));
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
