contract C
{
	function f() public view {
		uint g = gasleft();
		uint flag = gasleft() > g ? 1 : 0;
		assert(flag == 0);
	}
}
// ====
// EVMVersion: <amsterdam
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (77-90): BMC: Condition is always false.
