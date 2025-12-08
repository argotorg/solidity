contract D {
}

contract C {
	struct S {
		D d;
		function () external returns (uint) f;
	}

	S public s;

	function test() public view {
		(D d, function () external returns (uint) f) = this.s();
		assert(d == s.d); // should hold
		assert(address(d) == address(this)); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9170: (206-214): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Warning 2072: (146-183): Unused local variable.
// Warning 8364: (187-193): Assertion checker does not yet implement type function () view external returns (contract D,function () external returns (uint256))
// Warning 6328: (234-269): CHC: Assertion violation happens here.\nCounterexample:\ns = {d: 0, f: 0}\nd = 0\nf = 0\n\nTransaction trace:\nC.constructor()\nState: s = {d: 0, f: 0}\nC.test()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
