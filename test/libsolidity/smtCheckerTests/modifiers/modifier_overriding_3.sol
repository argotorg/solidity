abstract contract A {
	bool s;

	function f() public mod {
		assert(s); // holds for B
		assert(!s); // fails for B
	}
	modifier mod() virtual;
}

contract B is A {
	modifier mod() virtual override {
		bool x = true;
		s = x;
		_;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 8429: (120-143): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (166-233): Virtual modifiers are deprecated and scheduled for removal.
// Warning 2018: (33-118): Function state mutability can be restricted to view
// Warning 6328: (89-99): CHC: Assertion violation happens here.\nCounterexample:\ns = true\nx = true\n\nTransaction trace:\nB.constructor()\nState: s = false\nA.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
