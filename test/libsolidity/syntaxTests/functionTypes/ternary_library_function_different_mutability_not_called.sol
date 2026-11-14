library L {
	function f() public returns (uint) {}
	function g() public pure returns (uint) {}
}

contract C {
	function test(bool b) public {
		b ? L.f : L.g;
	}
}
// ----
// Warning 2018: (112-162): Function state mutability can be restricted to pure
