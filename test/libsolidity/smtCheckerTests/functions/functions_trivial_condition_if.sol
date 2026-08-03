contract C
{
	function f(bool x) public pure { require(x); if (x) {} }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (63-64): BMC: Condition is always true.
