contract B {
    function f() mod2("0123456") pure public { }
    modifier mod2(bytes7 a) {
		assert(a == "0123456");
		assert(a == "1234567");
		_;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (120-142): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x30313233343536\n\nTransaction trace:\nB.constructor()\nB.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
