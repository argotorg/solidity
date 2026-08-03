contract C
{
	function f(uint16 x) public pure {
		uint8 y = uint8(x);
		// True because of y's type
		assert(y < 300);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
