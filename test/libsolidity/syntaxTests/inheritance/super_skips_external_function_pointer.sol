contract A {
    function f() public virtual returns (uint256) { return 1; }
}


contract X {
    function f() external virtual returns (uint256) { return 100; }
}


// Binding super.f to an internal function pointer rather than calling it directly.
contract B is A {
    function f() public virtual override returns (uint256) {
        function () internal returns (uint256) p = super.f;
        return p();
    }
}


contract D is A, X, B {
    function f() public override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
// TypeError 8476: (380-387): This "super" call would have to skip external function "X.f" in the linearization of contract "D". External functions have no internal entry point and can never be reached through "super". Declare "X.f" as public or reorder the inheritance hierarchy.
