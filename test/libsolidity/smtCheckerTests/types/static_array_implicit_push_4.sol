contract D {
	int16[] inner;
	int[][] data;
	function t() public {
		data.push(inner);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
