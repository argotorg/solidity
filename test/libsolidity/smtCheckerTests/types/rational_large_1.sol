contract c {
	function f() public pure returns (uint) {
		uint x = 8e130%9;
		assert(x == 8);
		assert(x != 8);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6321: (48-52): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6328: (96-110): CHC: Assertion violation happens here.\nCounterexample:\n\n = 0\nx = 8\n\nTransaction trace:\nc.constructor()\nc.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
