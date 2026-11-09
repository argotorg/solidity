contract C {
	function a() internal pure {}
	function b() internal pure {}

	function voidFunctions(uint8 x, bool c) public pure {
		c ? a() : b();
		assert(uint256(x) + 1 > uint256(x)); // should hold
	}

	function emptyTuples(uint8 x, bool c) public pure {
		c ? () : ();
		assert(uint256(x) + 1 > uint256(x)); // should hold
	}
}
// ====
// SMTEngine: all
// SMTShowProvedSafe: yes
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 9576: (157-171): CHC: Overflow (resulting value larger than 2**256 - 1) check is safe!
// Info 9576: (150-185): CHC: Assertion violation check is safe!
// Info 9576: (283-297): CHC: Overflow (resulting value larger than 2**256 - 1) check is safe!
// Info 9576: (276-311): CHC: Assertion violation check is safe!
