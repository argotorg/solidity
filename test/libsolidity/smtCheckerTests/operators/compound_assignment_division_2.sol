contract C {
	uint[] array;
	constructor() {
		q(); q();
	}
	function q() public {
		array.push();
	}
	function f(uint x, uint p) public {
		require(p < array.length);
		require(x == 2);
		array[p] = 10;
		array[p] /= array[p] / x;
		assert(array[p] == x);
		assert(array[p] == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (259-280): CHC: Assertion violation happens here.\nCounterexample:\narray = [2, 0]\nx = 2\np = 0\n\nTransaction trace:\nC.constructor()\nState: array = [0, 0]\nC.f(2, 0)
// Info 1391: CHC: 8 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
