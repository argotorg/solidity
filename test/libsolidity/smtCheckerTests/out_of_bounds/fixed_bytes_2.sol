contract C {
	function r(bytes4 x, uint y) public pure returns (bytes1) {
		return x[y]; // oob access
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6368: (83-87): CHC: Out of bounds access happens here.\nCounterexample:\n\nx = 0x0\ny = 4\n = 0x0\n\nTransaction trace:\nC.constructor()\nC.r(0x0, 4)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
