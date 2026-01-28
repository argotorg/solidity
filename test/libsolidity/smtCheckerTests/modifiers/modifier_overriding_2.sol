abstract contract A {
	bool s;

	function f() public view mod {
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
// Warning 8429: (113-136): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (159-213): Virtual modifiers are deprecated and scheduled for removal.
// Warning 6328: (66-75): CHC: Assertion violation happens here.\nCounterexample:\ns = false\n\nTransaction trace:\nB.constructor()\nState: s = false\nA.f()
