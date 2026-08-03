contract c {
	bool b = (f() == 0) && (f() == 0);
	function f() internal returns (uint) {}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
