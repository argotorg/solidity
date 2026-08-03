contract C {
	uint[] a;
	function f(uint l) public {
		for (uint i = 0; i < l; ++i) {
			a.push();
			a.pop();
		}
		a.pop();
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2529: (117-124): CHC: Empty array "pop" happens here.\nCounterexample:\na = []\nl = 0\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f(0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
