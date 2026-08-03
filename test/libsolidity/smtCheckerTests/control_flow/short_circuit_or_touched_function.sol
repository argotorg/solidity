contract C
{
	bool b;
	function g(bool _b) internal returns (bool) {
		b = _b;
		return b;
	}
	function f() public {
		if (g(true) || (b == false)) {}
		if ((b == true) || g(false)) {}
		if (g(true) || g(false)) {}
		if (g(true) || (b == false)) {}
		if (g(false) || b) {}
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (123-146): BMC: Condition is always true.
// Warning 6838: (157-180): BMC: Condition is always true.
// Warning 6838: (191-210): BMC: Condition is always true.
// Warning 6838: (221-244): BMC: Condition is always true.
// Warning 6838: (255-268): BMC: Condition is always false.
