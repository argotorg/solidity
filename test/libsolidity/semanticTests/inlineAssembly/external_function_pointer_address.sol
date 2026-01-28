contract C {
	function testFunction() external {}

	function testYul() public returns (address adr) {
		function() external fp = C(address(0x1234)).testFunction;

		assembly {
			adr := fp.address
		}
	}
	function testSol() public returns (address) {
		return C(address(0x1234)).testFunction.address;
	}
}
// ----
// testYul() -> 0x1234
// testSol() -> 0x1234
