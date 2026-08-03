contract C
{
	bool b;
	function f() public {
		if ((b = true) || (b == false)) {}
		if ((b == true) || (b = false)) {}
		if ((b = true) || (b = false)) {}
		if ((b == true) || (b == false)) {}
		if ((b = false) || b) {}
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (51-77): BMC: Condition is always true.
// Warning 6838: (88-114): BMC: Condition is always true.
// Warning 6838: (125-150): BMC: Condition is always true.
// Warning 6838: (161-188): BMC: Condition is always true.
// Warning 6838: (199-215): BMC: Condition is always false.
