contract C {
	function f(bytes calldata x) external pure {
		x[:18726387213];
		x[18726387213:];
		x[18726387213:111111111111111111];
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
