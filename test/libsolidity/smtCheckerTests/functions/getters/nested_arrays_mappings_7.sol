contract C {
	mapping (uint => uint)[] public m;

	constructor() {
		m.push();
		m[0][1] = 42;
	}

	function f() public view {
		uint y = this.m(0,1);
		assert(y == m[0][1]); // should hold
		assert(y == 1); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (192-206): CHC: Assertion violation happens here.\nCounterexample:\n\ny = 42\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
