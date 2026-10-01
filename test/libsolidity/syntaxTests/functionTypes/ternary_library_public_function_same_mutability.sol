library L {
	function f() public returns (uint) {}
	function g() public returns (uint) {}
}

contract C {
	function test(bool b) public returns (uint) {
		return (b ? L.f : L.g)();
 	}
}
// ----
