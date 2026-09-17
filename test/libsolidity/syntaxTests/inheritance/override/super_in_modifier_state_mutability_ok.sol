contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}


contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}


// super.f() in m resolves to X.f in D, but g is nonpayable, so it may.
contract B is A {
    modifier m() { super.f(); _; }
    function g() public m returns (uint256) { return 2; }
}


contract D is A, X, B {
    function f() public pure override(A, X) returns (uint256) { return 7; }
}
// ----
