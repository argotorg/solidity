contract C {
	function(uint) returns (uint) a;
	function(uint) returns (uint) b;
	function f(function(uint) returns (uint) g, function(uint) returns (uint) h) internal {
		assert(g(2) == h(2));
	}
	function g() public {
		f(a, b);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2519: (93-124): This declaration shadows an existing declaration.
// Warning 6031: (179-183): Internal error: Expression undefined for SMT solver.
// Warning 6031: (187-191): Internal error: Expression undefined for SMT solver.
// Warning 6328: (172-192): CHC: Assertion violation happens here.\nCounterexample:\na = 0, b = 0\n\nTransaction trace:\nC.constructor()\nState: a = 0, b = 0\nC.g()\n    C.f(0, 0) -- internal call
