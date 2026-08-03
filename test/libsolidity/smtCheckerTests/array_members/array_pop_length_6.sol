contract C {
	uint[] a;
	function g() internal view {
		a.length;
	}
	function f() public {
		a.pop();
		g();
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2529: (94-101): CHC: Empty array "pop" happens here.\nCounterexample:\na = []\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
