library L {
	function value(function()internal a, uint256 b) internal {}
}
contract C {
	using L for function()internal;

	function f() public {
		function()internal x;
		x.value(42);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
