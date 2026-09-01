abstract contract A {
	bool s;

	function f() public mod {
		assert(s); // holds for C, but fails for B
	}
	modifier mod() virtual;
}

contract B is A {
	modifier mod() virtual override {
		s = false;
		_;
	}
}

contract C is B {
	modifier mod() override {
		s = true;
		_;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 8429: (108-131): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (154-208): Virtual modifiers are deprecated and scheduled for removal.
// Warning 2018: (33-106): Function state mutability can be restricted to view
// Warning 6328: (61-70): CHC: Assertion violation happens here.\nCounterexample:\ns = false\n\nTransaction trace:\nB.constructor()\nState: s = false\nA.f()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
