contract C {
	mapping (uint => uint) map;
	function f(uint x, uint p) public {
		require(x == 2);
		map[p] = 10;
		map[p] /= map[p] / x;
		assert(map[p] == x);
		assert(map[p] == 0);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Warning 6328: (162-181): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 2\np = 0\n\nTransaction trace:\nC.constructor()\nC.f(2, 0)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
