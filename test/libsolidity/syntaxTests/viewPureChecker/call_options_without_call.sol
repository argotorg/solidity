contract C {
    function f() external payable {}
	function g(address a) external pure {
		a.call{value: 42};
	}
	function h() external view {
		this.f{value: 42};
	}
}
