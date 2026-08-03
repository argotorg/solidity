abstract contract D
{
	function g(uint x) public virtual;
}

contract C
{
	uint x;
	function f(uint y, D d) public {
		require(x == y);
		assert(x == y);
		d.g(y);
		// Storage knowledge is cleared after an external call.
		assert(x == y);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreInv: yes
// SMTIgnoreOS: macos
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
