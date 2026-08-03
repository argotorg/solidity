contract C
{
	function f() public pure {
		uint16 a = 0x1234;
		uint32 b = uint32(a); // b will be 0x00001234 now
		// This is correct (left padding).
		assert(a == b);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
