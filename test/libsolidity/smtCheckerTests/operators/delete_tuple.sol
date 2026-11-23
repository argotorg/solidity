contract A{
	function f() public pure {
		delete ([""][0]);
	}
}
// ====
// SMTEngine: all
// ----
// TypeError 5986: (50-57): Cannot modify part of a temporary value, the change would be lost.
