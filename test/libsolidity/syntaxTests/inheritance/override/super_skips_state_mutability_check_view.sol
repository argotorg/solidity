contract A {
    function f() public view virtual returns (uint256) { return 1; }
}


contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}


contract B is A {
    function f() public view virtual override returns (uint256) { return super.f(); }
}


// As super_skips_state_mutability_check, but view, which the EVM enforces.
contract D is A, X, B {
    function f() public view override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
// TypeError 7898: (289-298): Function "B.f" declared as view, but this "super" call resolves to a function with higher state mutability in a derived contract.
