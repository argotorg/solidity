contract C {
	uint x = f(2);
	constructor () {
		assert(x == 2);
	}

	function f(uint y) internal view returns (uint) {
		assert(y > 0);
		assert(x == 0);
		return y;
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
