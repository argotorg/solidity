contract A {
	uint[] a;
	function f() public {
		A.a.push(2);
		assert(A.a[A.a.length - 1] == 2);
		A.a.pop();
		// Fails
		assert(A.a.length > 0);
		assert(A.a.length == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (124-146): CHC: Assertion violation happens here.\nCounterexample:\na = []\n\nTransaction trace:\nA.constructor()\nState: a = []\nA.f()
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
