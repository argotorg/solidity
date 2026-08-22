contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}
contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}
contract B is A {
    function f() public pure virtual override returns (uint256) { return super.f(); }
}
contract D is A, X, B {
    function f() public pure override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
// TypeError 7557: (285-294): Function cannot be declared as pure because this "super" call resolves to a function that (potentially) modifies the state in the linearization of a contract inheriting from this one.
