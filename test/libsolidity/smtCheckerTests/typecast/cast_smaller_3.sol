contract C
{
	function f() public pure {
		bytes2 a = 0x1234;
		bytes1 b = bytes1(a); // b will be 0x12
		assert(b == 0x12);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
