contract C
{
	struct S { uint[] a; }
	function f(bool b) public pure {
		S memory c;
		c.a = new uint[](2);
		c.a[0] = 0;
		if (b)
			c.a[0] = 1;
		else
			c.a[0] = 2;
		assert(c.a[0] > 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
