abstract contract A {
	int x = 0;

	function f() public mod() {
		assert(x != 0); // does not hold for A, but A is abstract so it should not be reported
		assert(x != 1); // fails for B
		assert(x != 2); // fails for C
		assert(x != 3); // fails for D
	}

	modifier mod() virtual {
		_;
	}
}

contract B is A {
	modifier mod() virtual override {
		x = 1;
		_;
	}
}

contract C is A {
	modifier mod() virtual override {
		x = 2;
		_;
	}
}

contract D is B,C {
	modifier mod() virtual override (B,C){
		x = 3;
		_;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 8429: (257-289): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (312-362): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (385-435): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (460-515): Virtual modifiers are deprecated and scheduled for removal.
// Warning 2018: (36-254): Function state mutability can be restricted to view
// Warning 6328: (155-169): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\n\nTransaction trace:\nB.constructor()\nState: x = 0\nA.f()
// Warning 6328: (188-202): CHC: Assertion violation happens here.\nCounterexample:\nx = 2\n\nTransaction trace:\nC.constructor()\nState: x = 0\nA.f()
// Warning 6328: (221-235): CHC: Assertion violation happens here.\nCounterexample:\nx = 3\n\nTransaction trace:\nD.constructor()\nState: x = 0\nA.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
