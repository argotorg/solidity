abstract contract A {
	function f() public mod {}
	modifier mod virtual;
}
// ====
// SMTEngine: all
// ----
// Warning 8429: (51-72): Virtual modifiers are deprecated and scheduled for removal.
