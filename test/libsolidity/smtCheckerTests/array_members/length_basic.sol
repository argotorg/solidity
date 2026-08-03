contract C {
	uint[] arr;
	function f() public view {
		uint x = arr.length;
		uint y = x;
		assert(arr.length == y);
		assert(arr.length != y);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (120-143): CHC: Assertion violation happens here.\nCounterexample:\narr = []\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nState: arr = []\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
