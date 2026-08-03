contract C
{
	function f() public pure {
		assembly {
		}
	}
}
// ====
// SMTEngine: all
// ----
// Warning 7737: (43-57): Inline assembly may cause SMTChecker to produce spurious warnings (false positives).
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
