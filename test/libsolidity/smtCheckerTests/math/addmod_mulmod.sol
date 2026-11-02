contract C {
	function test() public pure {
		uint x;
		if ((2**255 + 2**255) % 7 != addmod(2**255, 2**255, 7)) x = 1;
		if ((2**255 + 2**255) % 7 != addmod(2**255, 2**255, 7)) x = 2;
		assert(x == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
