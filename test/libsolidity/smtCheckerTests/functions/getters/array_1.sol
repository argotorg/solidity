contract C {
	uint[] public a;
	constructor() {
		a.push();
		a.push();
		a.push();
		a.push();
	}
	function f() public view {
		uint y = this.a(2);
		assert(y == a[2]); // should hold
		assert(y == 1); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (187-201): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0, 0, 0]\ny = 0\n\nTransaction trace:\nC.constructor()\nState: a = [0, 0, 0, 0]\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
