contract C
{
	struct S {
		uint x;
	}
	mapping (uint => S) smap;
	function f(uint y, uint v) public {
		if (0==1)
			smap[y] = S(v);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (108-112): BMC: Condition is always false.
