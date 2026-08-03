contract C {
	function f2() public pure returns(int) {
		int a;
		((((((, a)))),)) = ((1, 2), 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6321: (48-51): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
