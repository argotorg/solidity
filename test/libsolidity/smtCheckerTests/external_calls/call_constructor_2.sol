contract C {
	uint x;
	function f(uint _x) public {
		x = _x;
	}
	constructor(address _a) {
		_a.call("aaaa");
		assert(x == 0); // should hold
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9302: (94-109): Return value of low-level calls not used.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
