contract C {
	int public x;

	function f() public view {
		try this.x() returns (int v) {
			assert(x == v); // should hold
		} catch {
			assert(false); // this fails, because we over-approximate every external call in the way that it can both succeed and fail
		}
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (139-152): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
