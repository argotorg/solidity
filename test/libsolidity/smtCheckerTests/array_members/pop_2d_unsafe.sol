contract C {
	uint[][] a;
	function f() public {
		a.push();
		a.push();
		a[0].push();
		a[1].pop();
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2529: (90-100): CHC: Empty array "pop" happens here.\nCounterexample:\na = [[0], []]\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
