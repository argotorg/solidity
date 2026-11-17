contract C {
	function empty_tuple(uint8 x) public pure {
		true ? () : (); // bug fix test, proper handling of empty tuples
		assert(uint256(x) + 1 > uint256(x));
	}

	function non_empty_tuple() public pure {
		true ? (1, 2) : (3, 4);
	}

	function return_empty_tuple() public pure {
		return true ? () : ();
	}
}
// ====
// SMTEngine: chc
// ----
// Warning 6133: (60-74): Statement has no effect.
// Warning 6133: (212-234): Statement has no effect.
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
