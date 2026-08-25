contract A {
    function f() public virtual returns (uint256) { return 1; }
}


contract B is A {
    function f() public virtual override returns (uint256) { return super.f(); }
}


contract X {
    function f() external virtual returns (uint256) { return 100; }
}


// C3 linearization of D is [D, B, X, A]. `super.f()` in B would have to skip X.f(),
// which is external and therefore has no internal entry point.
contract D is A, X, B {
    function f() public override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
// TypeError 8476: (167-174): This "super" call would have to skip external function "X.f" in the linearization of contract "D". External functions have no internal entry point and can never be reached through "super". Declare "X.f" as public or reorder the inheritance hierarchy.
