library L {
	function f() public returns (uint) {}
	function g() public pure returns (uint) {}
}

contract C {
	function test(bool b) public returns (uint) {
		return (b ? L.f : L.g)();
	}
}
// ----
// TypeError 1080: (168-181): True expression's type function () returns (uint256) does not match false expression's type function () pure returns (uint256).
