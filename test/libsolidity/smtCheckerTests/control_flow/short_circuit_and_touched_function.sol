contract C
{
	bool b;
	function g(bool _b) internal returns (bool) {
		b = _b;
		return b;
	}
	function f() public {
		if (g(false) && (b == true)) {}
		if ((b == false) && g(true)) {}
		if (g(false) && g(true)) {}
		if (g(false) && (b == true)) {}
		if (g(true) && b) {}
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (123-146): BMC: Condition is always false.
// Warning 6838: (157-180): BMC: Condition is always true.
// Warning 6838: (191-210): BMC: Condition is always false.
// Warning 6838: (221-244): BMC: Condition is always false.
// Warning 6838: (255-267): BMC: Condition is always true.
