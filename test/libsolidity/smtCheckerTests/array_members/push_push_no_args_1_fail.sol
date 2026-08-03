contract C {
	int[][] array2d;
	function l() public {
		array2d.push().push();
		assert(array2d.length > 2);
		assert(array2d[array2d.length - 1].length > 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (81-107): CHC: Assertion violation happens here.\nCounterexample:\narray2d = [[0]]\n\nTransaction trace:\nC.constructor()\nState: array2d = []\nC.l()
// Warning 6328: (111-157): CHC: Assertion violation happens here.\nCounterexample:\narray2d = [[0]]\n\nTransaction trace:\nC.constructor()\nState: array2d = []\nC.l()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
