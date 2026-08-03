contract A {
	uint x;
	function f() internal {
		assert(x == 1);
		--x;
	}
}

contract C is A {
	constructor() {
		assert(x == 0);
		++x;
		f();
		assert(x == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
