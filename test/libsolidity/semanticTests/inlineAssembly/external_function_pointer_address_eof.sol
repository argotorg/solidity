contract C {
	function testFunction() external {}
	address contractAddress = address(this);
	function testYul() public returns (bool) {
		require(contractAddress != address(0));
		function() external fp = this.testFunction;

		address adr;
		assembly {
			adr := fp.address
		}

		return adr == contractAddress;
	}
	function testSol() public returns (bool) {
		require(contractAddress != address(0));
		return this.testFunction.address == contractAddress;
	}
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// testYul() -> true
// testSol() -> true
