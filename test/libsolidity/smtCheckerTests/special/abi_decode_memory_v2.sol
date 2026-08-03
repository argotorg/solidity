pragma abicoder v2;

contract C {
	struct S { uint x; uint[] b; }
	function f() public pure returns (S memory, bytes memory, uint[][2] memory) {
		return abi.decode("abc", (S, bytes, uint[][2]));
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
