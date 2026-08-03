contract C
{
	function f(uint x) public pure returns (uint) {
		assembly {
			x := 2
		}
		return x;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 7737: (64-88): Inline assembly may cause SMTChecker to produce spurious warnings (false positives).
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
