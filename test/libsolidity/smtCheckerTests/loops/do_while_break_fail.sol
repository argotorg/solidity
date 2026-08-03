contract C {
	function f() public pure {
		uint x;
		do {
			break;
			x = 1;
		} while (x == 0);
		assert(x == 1);
	}
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Warning 5740: (71-76): Unreachable code.
// Warning 5740: (89-95): Unreachable code.
// Warning 6328: (100-114): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
