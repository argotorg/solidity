contract C {
	function h() external pure {}

	function f(uint8 x) external view returns (bytes memory r) {
		r = abi.encodeCall(this.h, ());
		assert(uint256(x) + 1 > uint256(x));
	}
}
// ====
// SMTEngine: chc
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
