contract C {
	uint x = 5;

	constructor() {
		assert(x == 5);
		x = 10;
	}

	function f(uint y) public view {
		assert(y == x);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (112-126): CHC: Assertion violation happens here.\nCounterexample:\nx = 10\ny = 11\n\nTransaction trace:\nC.constructor()\nState: x = 10\nC.f(11)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
