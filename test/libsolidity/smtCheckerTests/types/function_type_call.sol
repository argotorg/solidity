contract C {
	function(uint) m_g;
    function f(function(uint) internal g) internal {
		g(2);
    }
	function h() public {
		f(m_g);
	}
}
// ====
// SMTEngine: all
// ----
