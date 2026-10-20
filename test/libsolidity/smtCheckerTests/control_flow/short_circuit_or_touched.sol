contract C
{
	bool b;
	function f() public {
		if ((b = true) || (b == false)) {}
		if ((b == true) || (b = false)) {}
		if ((b = true) || (b = false)) {}
		if ((b == true) || (b == false)) {}
		if ((b = false) || b) {}
	}
}
// ====
// SMTEngine: all
// ----
