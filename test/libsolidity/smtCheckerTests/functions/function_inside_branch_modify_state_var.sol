contract C
{
	uint x;
	function f() internal {
		require(x < 10000);
		x = x + 1;
	}
	function g(bool b) public {
		x = 0;
		if (b)
			f();
		// Should fail for `b == true`.
		assert(x == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (176-190): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\nb = true\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.g(true)\n    C.f() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
