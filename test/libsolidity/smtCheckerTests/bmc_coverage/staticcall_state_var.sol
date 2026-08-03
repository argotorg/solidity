contract C {
	uint x;
	function f(address _a) public {
		x = 2;
		_a.staticcall("");
		assert(x == 2); // should hold
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 9302: (66-83): Return value of low-level calls not used.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
