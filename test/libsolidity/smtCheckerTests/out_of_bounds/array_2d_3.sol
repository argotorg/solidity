contract C {
	uint[][] a;
	function p() public { a.push(); }
	function q(uint i) public {
		require(i < a.length);
		a[i].push();
	}
	function r() public view {
		for (uint i = 0; i < a.length; ++i)
			for (uint j = 0; j < a[i].length; ++j)
				a[i][j]; // safe access
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
