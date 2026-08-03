contract C {
	uint[] a;
	function f() public {
		a.pop();
		a.push();
		a.push();
		a.push();
		a.pop();
		a.pop();
		a.pop();
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2529: (49-56): CHC: Empty array "pop" happens here.\nCounterexample:\na = []\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
