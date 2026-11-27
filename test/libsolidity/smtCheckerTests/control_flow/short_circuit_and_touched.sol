contract C
{
	bool b;
	function f() public {
		if ((b = false) && (b == true)) {}
		if ((b == false) && (b = true)) {}
		if ((b = false) && (b = true)) {}
		if ((b == false) && (b == true)) {}
		if ((b = true) && b) {}
	}
}
// ====
// SMTEngine: all
// ----
