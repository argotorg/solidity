contract C {
	uint[][] arr;
	constructor() {
		arr.push();
		arr.push();
		arr.push();
		arr.push();
		arr.push();
		arr.push();
		arr.push();
		arr.push();
		arr.push();
	}
	function f() public {
		uint x = arr[2].length;
		uint y = arr[3].length;
		uint z = arr.length;
		uint t = arr[5].length;
		arr[5] = arr[8];
		assert(arr[2].length != x);
		assert(arr[3].length != y);
		assert(arr.length != z);
		assert(arr[5].length != t);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Warning 6328: (319-345): CHC: Assertion violation happens here.\nCounterexample:\narr = [[], [], [], [], [], [], [], [], []]\nx = 0\ny = 0\nz = 9\nt = 0\n\nTransaction trace:\nC.constructor()\nState: arr = [[], [], [], [], [], [], [], [], []]\nC.f()
// Warning 6328: (349-375): CHC: Assertion violation happens here.\nCounterexample:\narr = [[], [], [], [], [], [], [], [], []]\nx = 0\ny = 0\nz = 9\nt = 0\n\nTransaction trace:\nC.constructor()\nState: arr = [[], [], [], [], [], [], [], [], []]\nC.f()
// Warning 6328: (379-402): CHC: Assertion violation happens here.\nCounterexample:\narr = [[], [], [], [], [], [], [], [], []]\nx = 0\ny = 0\nz = 9\nt = 0\n\nTransaction trace:\nC.constructor()\nState: arr = [[], [], [], [], [], [], [], [], []]\nC.f()
// Warning 6328: (406-432): CHC: Assertion violation happens here.\nCounterexample:\narr = [[], [], [], [], [], [], [], [], []]\nx = 0\ny = 0\nz = 9\nt = 0\n\nTransaction trace:\nC.constructor()\nState: arr = [[], [], [], [], [], [], [], [], []]\nC.f()
// Info 1391: CHC: 8 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
