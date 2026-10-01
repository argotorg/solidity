library L {
	function f() external view returns (uint) {}
	function g() external pure returns (uint) {}
}

contract C {
	function test(bool b) public view returns (uint) {
		return (b ? L.f : L.g)();
	}
}
// ----
// TypeError 1080: (182-195): True expression's type function () view returns (uint256) does not match false expression's type function () pure returns (uint256).
