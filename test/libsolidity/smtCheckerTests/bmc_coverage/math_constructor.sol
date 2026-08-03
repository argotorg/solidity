contract C {
	uint z = 1;
	uint w = z - 3;
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4144: (36-41): BMC: Underflow (resulting value less than 0) happens here.
