contract C {
	uint[] a;
	function p() public { a.push(); }
	function r(uint i) public view returns (uint) {
		require(i < a.length);
		return a[i]; // safe access
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
