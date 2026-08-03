contract e {
	function f(uint[] calldata) internal {}
	function h(uint[] calldata c) external { f(c[:]); }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
