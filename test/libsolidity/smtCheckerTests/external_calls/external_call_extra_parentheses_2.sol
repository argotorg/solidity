contract D {
	function f() external {}
}

contract C {
	function g(D d) public {
		((d.f))();
	}
}
// ====
// SMTEngine: chc
// ----
