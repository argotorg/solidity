contract C
{
	enum D { Left, Right }
	D d;
	function f(D _a, D _b) public view {
		require(_a == _b);
		require(_a == d);
		assert(d == _b);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
