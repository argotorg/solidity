contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}


contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}


// Modifier m is inferred pure because super.f() in B statically binds to A.f.
// The C3 linearization of D is [D, B, X, A], where it resolves to X.f instead.
// m is not overridden anywhere and is not even virtual.
contract B is A {
    modifier m() { super.f(); _; }
    function g() public pure m returns (uint256) { return 2; }
}


contract D is A, X, B {
    function f() public pure override(A, X) returns (uint256) { return 7; }
}
// ----
// TypeError 1614: (436-466): Modifier "m" has state mutability "nonpayable" in "D", but "B.g", which uses it, is declared "pure".
