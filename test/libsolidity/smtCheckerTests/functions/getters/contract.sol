contract D {}

contract C {
	D public d;

	function f() public view {
		D e = this.d();
		assert(e == d); // should hold
		assert(address(e) == address(this)); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9170: (97-103): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Warning 6328: (123-158): CHC: Assertion violation happens here.\nCounterexample:\nd = 0\ne = 0\n\nTransaction trace:\nC.constructor()\nState: d = 0\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
