contract C
{
	enum D { Left, Right }
	function f(uint x) public pure {
		require(x == 0);
		D _a = D(x);
		assert(_a == D.Left);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
