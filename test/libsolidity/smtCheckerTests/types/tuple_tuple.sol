contract C {
	function f3() public pure {
		((, ), ) = ((7, 8), 9);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
