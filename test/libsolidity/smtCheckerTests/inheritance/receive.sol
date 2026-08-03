// 2 warnings, receive and A.g
contract A {
	uint x;

	receive () external virtual payable {
		assert(x == 1);
	}
	function g() public view {
		assert(x == 1);
	}
}

// 2 warnings, receive and A.g
contract B is A {
	uint y;

	receive () external payable override {
		assert(x == 1);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (95-109): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n\nTransaction trace:\nA.constructor()\nState: x = 0\nA.receive(){ msg.value: 5 }
// Warning 6328: (144-158): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n\nTransaction trace:\nA.constructor()\nState: x = 0\nA.g()
// Warning 6328: (267-281): CHC: Assertion violation happens here.\nCounterexample:\ny = 0, x = 0\n\nTransaction trace:\nB.constructor()\nState: y = 0, x = 0\nB.receive(){ msg.value: 19 }
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
