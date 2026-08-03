contract C {
	int[][] array2d;
	function l() public {
		array2d.push().push();
		assert(array2d.length > 0);
		assert(array2d[array2d.length - 1].length > 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
