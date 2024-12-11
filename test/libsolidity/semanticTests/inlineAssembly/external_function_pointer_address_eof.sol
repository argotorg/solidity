contract C {
	function testFunction() external {}

	function testYul() public returns (address adr) {
		function() external fp = this.testFunction;

		assembly {
			adr := fp.address
		}
	}
	function testSol() public returns (address) {
		return this.testFunction.address;
	}
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// testYul() -> 0x0b4a2e943bbeb51ee55e5785a597202569667e7b
// testSol() -> 0x0b4a2e943bbeb51ee55e5785a597202569667e7b
