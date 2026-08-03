contract C {
	int[][] array2d;
	function l() public {
		s().push();
		// False positive.
		// Knowledge is erased because `s()` is a storage pointer.
		assert(array2d[2].length > 0);
	}
	function s() internal returns (int[] storage) {
		array2d.push();
		array2d.push();
		array2d.push();
		return array2d[2];
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6368: (159-169): CHC: Out of bounds access happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nState: array2d = []\nC.l()\n    C.s() -- internal call
// Warning 6328: (152-181): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nState: array2d = []\nC.l()\n    C.s() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
