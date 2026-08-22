contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}
contract X is A {
    function f() public pure virtual override returns (uint256) { return 2; }
}
contract B is A {
    function f() public pure virtual override returns (uint256) { return super.f(); }
}
contract D is A, X, B {
    function f() public pure override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
