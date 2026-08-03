contract C
{
	function f(int8 x) public pure {
		x = 127;
		int8 y;
		unchecked { y = x + 1; }
		assert(y == -128);
		unchecked { y = x + 127; }
		assert(y == -2);
		x = -127;
		unchecked { y = x + -127; }
		assert(y == 2);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
