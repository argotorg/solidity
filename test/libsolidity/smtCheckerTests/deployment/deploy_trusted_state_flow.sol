contract D {
	uint x;
	function inc() public { ++x; }
	function f() public view returns (uint) { return x; }
}

contract C {
	D d;
	constructor() {
		d = new D();
		assert(d.f() == 0); // should hold
	}
	function g() public view {
		assert(d.f() == 0); // should fail
	}
}
// ====
// SMTEngine: all
// SMTExtCalls: trusted
// SMTIgnoreOS: macos
// ----
// Warning 4984: (47-50): CHC: Overflow (resulting value larger than 2**256 - 1) might happen here.
// Warning 6328: (233-251): CHC: Assertion violation happens here.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 2661: (47-50): BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
