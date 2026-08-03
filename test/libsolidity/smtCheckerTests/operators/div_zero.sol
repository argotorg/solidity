contract C {
	uint z = 0;
	uint x = 2 / z;
}
// ====
// SMTEngine: all
// ----
// Warning 4281: (36-41): CHC: Division by zero happens here.\nCounterexample:\nz = 0, x = 0\n\nTransaction trace:\nC.constructor()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
