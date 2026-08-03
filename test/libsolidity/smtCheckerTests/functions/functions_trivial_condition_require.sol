contract C
{
	function f(bool x) public pure { x = true; require(x); }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (65-66): BMC: Condition is always true.
