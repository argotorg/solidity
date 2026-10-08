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
