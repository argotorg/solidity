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

// B.f is unreachable in D, but it is still rejected: its declared mutability must hold
// wherever it is inherited, not only where it happens to be called.
abstract contract D is A, X, B {
    function f() public pure virtual override(A, X, B) returns (uint256) { return 7; }
}
// ----
// TypeError 7898: (287-296): Function "B.f" declared as pure, but this "super" call resolves to a function with higher state mutability in a derived contract.
