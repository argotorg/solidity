contract C
{
	function f() public pure {
		uint[3] memory array = [uint(1), 2, 3];
		assert(array[0] == 1);
		assert(array[1] == 2);
		assert(array[2] == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
