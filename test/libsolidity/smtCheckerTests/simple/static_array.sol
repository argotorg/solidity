contract C
{
	// Used to crash because Literal had no type
	int[3] d;
	// Used to crash because Literal had no type
	int[3*1] x;
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
