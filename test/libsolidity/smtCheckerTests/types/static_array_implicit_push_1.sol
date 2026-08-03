contract C {
	uint[][] a;
	function f(uint[1] memory x) public {
		a.push(x);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
