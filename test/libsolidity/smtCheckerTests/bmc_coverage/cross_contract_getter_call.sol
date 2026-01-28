contract C {
	D internal d;
	constructor() {
		d = new D();
	}
	function invokeAndCheck() public {
		d.set();
		assert(d.n() <= 1);
	}
}

contract D {
	uint public n;
	function set() external {
		n = 1;
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 8729: (51-58): Contract deployment is only supported in the trusted mode for external calls with the CHC engine.
// Warning 4661: (112-130): BMC: Assertion violation happens here.
