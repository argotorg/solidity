contract K {
	function f() public pure {
		(abi.encode, "");
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6133: (43-59): Statement has no effect.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
