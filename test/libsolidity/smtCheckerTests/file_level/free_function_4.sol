function f()pure {
	ufixed a = uint64(1) + ufixed(2);
}
// ====
// SMTEngine: all
// ----
// Warning 2072: (20-28): Unused local variable.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
