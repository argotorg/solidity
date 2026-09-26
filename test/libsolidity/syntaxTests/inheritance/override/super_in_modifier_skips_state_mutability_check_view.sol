contract A {
    function f() public view virtual returns (uint256) { return 1; }
}


contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}


// As super_in_modifier_skips_state_mutability_check, but view.
contract B is A {
    modifier m() { super.f(); _; }
    function g() public view m returns (uint256) { return 2; }
}


contract D is A, X, B {
    function f() public view override(A, X) returns (uint256) { return s; }
}
// ----
// TypeError 1614: (284-314): Modifier "m" has state mutability "nonpayable" in "D", but "B.g", which uses it, is declared "view".
