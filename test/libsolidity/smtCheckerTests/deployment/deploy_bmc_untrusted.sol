contract D {
	uint x;
	function f() public view returns (uint) { return x; }
}

contract C {
	function g() public {
		D d = new D();
		uint y = d.f();
		assert(y == 0); // should fail in ext calls untrusted mode
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 8729: (124-131): Contract deployment is only supported in the trusted mode for external calls with the CHC engine.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (153-167): BMC: Assertion violation happens here.
