contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}
contract X {
    uint256 public s;
    function f() public view virtual returns (uint256) { return s; }
}
contract B is A {
    function f() public pure virtual override returns (uint256) { return super.f(); }
}
contract D is A, X, B {
    function f() public pure override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
// TypeError 7557: (281-290): Function cannot be declared as pure because this "super" call resolves to a function that (potentially) reads from the environment or state in the linearization of a contract inheriting from this one.
