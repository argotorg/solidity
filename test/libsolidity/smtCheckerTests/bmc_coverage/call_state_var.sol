contract C {
	uint x;
	function f(address _a) public {
		x = 2;
		_a.call("");
		assert(x == 2); // should fail
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 9302: (66-77): Return value of low-level calls not used.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (81-95): BMC: Assertion violation happens here.
