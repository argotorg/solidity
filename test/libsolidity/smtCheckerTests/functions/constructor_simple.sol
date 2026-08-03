contract C {
	uint x;

	constructor() {
		assert(x == 0);
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
// Warning 6328: (108-122): CHC: Assertion violation happens here.\nCounterexample:\nx = 10\ny = 0\n\nTransaction trace:\nC.constructor()\nState: x = 10\nC.f(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
