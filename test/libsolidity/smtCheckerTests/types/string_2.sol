contract C
{
	function f() public pure {
		string memory s = "Hello World";
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2072: (43-58): Unused local variable.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
