contract C {
	uint[][] a;
	function f(uint[] memory x, uint y) public {
		a.push(x);
		a[0].push(y);
		a[0].pop();
		assert(a[0][a[0].length - 1] == y);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 3944: (129-144): CHC: Underflow (resulting value less than 0) happens here.\nCounterexample:\na = [[]]\nx = []\ny = 0\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f([], 0)
// Warning 6328: (117-151): CHC: Assertion violation happens here.\nCounterexample:\n\ny = 0\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f(x, 0) -- counterexample incomplete; parameter name used instead of value
// Info 1391: CHC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
