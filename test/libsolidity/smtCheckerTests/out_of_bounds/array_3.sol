contract C {
	uint[] a;
	function r(uint i) public view returns (uint) {
		return a[i]; // oob access
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6368: (82-86): CHC: Out of bounds access happens here.\nCounterexample:\na = []\ni = 0\n = 0\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.r(0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
