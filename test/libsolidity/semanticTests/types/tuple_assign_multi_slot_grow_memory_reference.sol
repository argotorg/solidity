contract C {
	function f() public pure returns (bytes32, bytes memory, uint) {
		bytes memory bSource = "xyz";
		bytes memory bTarget;
		bytes32 c;
		uint x;
		((c, bTarget), x) = (("abc", bSource), 42);
		return (c, bTarget, x);
	}
}
// ----
// f() -> 0x6162630000000000000000000000000000000000000000000000000000000000, 0x60, 0x2a, 3, 0x78797a0000000000000000000000000000000000000000000000000000000000
