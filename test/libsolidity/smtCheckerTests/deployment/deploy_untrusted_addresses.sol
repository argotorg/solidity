contract D {
	uint x;
}

contract C {
	function f() public {
		D d1 = new D();
		D d2 = new D();

		assert(d1 != d2); // should fail in ext calls untrusted mode
		assert(address(this) != address(d1)); // should fail in ext calls untrusted mode
		assert(address(this) != address(d2)); // should fail in ext calls untrusted mode
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9170: (107-115): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Warning 8729: (70-77): Contract deployment is only supported in the trusted mode for external calls with the CHC engine.
// Warning 8729: (88-95): Contract deployment is only supported in the trusted mode for external calls with the CHC engine.
// Warning 6328: (100-116): CHC: Assertion violation happens here.\nCounterexample:\n\nd1 = 0\nd2 = 0\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (163-199): CHC: Assertion violation happens here.\nCounterexample:\n\nd1 = 11797\nd2 = 11797\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (246-282): CHC: Assertion violation happens here.\nCounterexample:\n\nd1 = 8855\nd2 = 8855\n\nTransaction trace:\nC.constructor()\nC.f()
