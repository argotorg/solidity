contract B {
    function f() pure public {
		g("0123456");
	}
    function g(bytes7 a) pure public {
		assert(a == "0123456");
		assert(a == "1234567");
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (104-126): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\n\nTransaction trace:\nB.constructor()\nB.g(0x0)
// Warning 6328: (130-152): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\n\nTransaction trace:\nB.constructor()\nB.g(0x0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
