contract C {
	function f(int a, uint b) public view {
		a >>= tx.gasprice;
		require(a == 16 && b == 2);
		a >>= b;
		assert(a == 4); // should hold
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
