contract C
{
	function f(bool x) public pure { require(x); }
	function g() public pure { f(true); }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
