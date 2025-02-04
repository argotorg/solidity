contract C {
	function f() external {}
	function g() public {
		(this.f)();
	}
}
// ====
// SMTEngine: chc
// ----
