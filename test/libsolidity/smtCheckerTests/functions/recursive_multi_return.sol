contract C {
	function g() public pure returns (uint, uint) {
		uint a;
		uint b;
		(a, b) = g();
	}
}
//
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
