contract C
{
	function f(bytes memory b) public pure returns (bytes memory) {
		bytes memory c = b;
		return b;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2072: (80-94): Unused local variable.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
