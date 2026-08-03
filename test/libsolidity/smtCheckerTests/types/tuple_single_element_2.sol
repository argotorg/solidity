contract C {
	function f() public pure {
		(("", ""));
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6133: (43-53): Statement has no effect.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
