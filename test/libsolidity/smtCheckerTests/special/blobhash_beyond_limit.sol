contract C {
	function f(uint index) public view {
		uint limit = 9; // Since PECTRA
		require(index >= limit);
		assert(blobhash(index) == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
