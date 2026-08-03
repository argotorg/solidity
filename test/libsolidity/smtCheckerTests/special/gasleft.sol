contract C
{
	function f() public view {
		assert(gasleft() > 0);
		uint g = gasleft();
		assert(g < gasleft());
		assert(g >= gasleft());
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (43-64): CHC: Assertion violation happens here.\nCounterexample:\n\ng = 0\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (90-111): CHC: Assertion violation happens here.\nCounterexample:\n\ng = 0\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
