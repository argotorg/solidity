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
