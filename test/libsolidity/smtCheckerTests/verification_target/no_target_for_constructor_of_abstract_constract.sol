abstract contract A {
	constructor() {
		assert(false); // A cannot be deployed, so this should not be reported
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
