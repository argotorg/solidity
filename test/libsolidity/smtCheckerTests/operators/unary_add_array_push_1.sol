contract C {
	uint[] x;
	function f() public {
		require(x.length == 0);
		++x.push();
		assert(x.length == 1);
		assert(x[0] == 1); // should hold
		assert(x[0] == 42); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (150-168): CHC: Assertion violation happens here.\nCounterexample:\nx = [1]\n\nTransaction trace:\nC.constructor()\nState: x = []\nC.f()
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
