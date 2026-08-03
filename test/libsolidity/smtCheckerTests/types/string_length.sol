contract C {
	function f() public pure {
		string memory x = "Hello World";
		assert(bytes(x).length == 11);
	}
	function g() public pure {
		string memory x = unicode"Hello World";
		assert(bytes(x).length == 11);
	}
	function h() public pure {
		bytes memory x = unicode"Hello World";
		string memory y = string(x);
		assert(bytes(y).length == 11);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
