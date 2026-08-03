contract C
{
	function f(bool b, uint[] memory c) public pure {
		require(c.length >= 1 && c.length <= 2);
		c[0] = 0;
		if (b)
			c[0] = 1;
		assert(c[0] > 0);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (143-159): CHC: Assertion violation happens here.\nCounterexample:\n\nb = false\nc = [0, 14]\n\nTransaction trace:\nC.constructor()\nC.f(false, [21655, 14])
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
