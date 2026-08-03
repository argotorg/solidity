contract C {
	function f(bool b, uint a) pure public {
		require(a <= 256);
		if (b)
			revert();
		uint c = a + 1;
		if (b)
			c--;
		else
			c++;
		assert(c == a);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (150-164): CHC: Assertion violation happens here.\nCounterexample:\n\nb = false\na = 0\nc = 2\n\nTransaction trace:\nC.constructor()\nC.f(false, 0)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (122-123): BMC: Condition is always false.
