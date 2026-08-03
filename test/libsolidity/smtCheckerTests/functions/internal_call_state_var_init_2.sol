contract c {
	uint x;
	function f() internal returns (uint) {
		x = x + 1;
	}
	bool b = (f() > 0) || (f() > 0);
}
// ====
// SMTEngine: all
// ----
// Warning 6321: (54-58): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
