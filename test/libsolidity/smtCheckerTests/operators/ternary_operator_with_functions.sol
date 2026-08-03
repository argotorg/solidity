contract C {
	function f() public {}
	function g() public {}

	function test() public {
		true ? f() : g();
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
