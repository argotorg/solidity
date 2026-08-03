contract A {
	uint x;
	constructor() {
		x = 2;
	}
}

contract B is A {
	constructor() A() {
		x = 3;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
