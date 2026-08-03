contract C
{
	mapping (uint => uint) map;
	function f() public {
		map[1] = 111;
		uint x = map[2];
		map[1] = 112;
		assert(map[2] == x);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
