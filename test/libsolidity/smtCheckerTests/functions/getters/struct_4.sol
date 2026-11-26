contract D {
}

contract C {
	struct S {
		D d;
		function () external returns (uint) f;
	}

	S public s;

	function test() public view {
		S memory r = this.s();
		assert(r.d == s.d); // should hold
		assert(address(r.d) == address(this)); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9170: (172-182): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Warning 6328: (202-239): CHC: Assertion violation happens here.\nCounterexample:\ns = {d: 0, f: 0}\nr = {d: 0, f: 0}\n\nTransaction trace:\nC.constructor()\nState: s = {d: 0, f: 0}\nC.test()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
