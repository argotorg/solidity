contract C {
	uint[][] a;
	function f() public {
		a.push();
		a[a.length - 1].push();
		assert(a[a.length - 1][0] == 100);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (89-122): CHC: Assertion violation happens here.\nCounterexample:\na = [[0]]\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f()
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
