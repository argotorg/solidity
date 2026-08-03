abstract contract A {
	function f() public mod {}
	modifier mod virtual;
}
// ====
// SMTEngine: all
// ----
// Warning 8429: (51-72): Virtual modifiers are deprecated and scheduled for removal.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
