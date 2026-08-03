contract C
{
	address owner;
	modifier m {
		if (true)
			owner = g();
		_;
	}
	function f() m public {
	}
	function g() public pure returns (address) {
		address a;
		a = address(0);
		return a;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
