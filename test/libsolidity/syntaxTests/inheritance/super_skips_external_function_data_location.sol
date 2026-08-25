contract A {
    function f(uint256[] memory a) public virtual returns (uint256) { return a.length; }
}


contract X {
    function f(uint256[] calldata a) external virtual returns (uint256) { return a.length + 1000; }
}


contract B is A {
    function f(uint256[] memory a) public virtual override returns (uint256) { return super.f(a); }
}


// Overriding external calldata parameters with public memory ones is allowed, so the
// candidate matching compares parameters only after normalising calldata to memory.
contract D is A, X, B {
    function f(uint256[] memory a) public override(A, X, B) returns (uint256) { return super.f(a); }
}
// ----
// TypeError 8476: (327-334): This "super" call would have to skip external function "X.f" in the linearization of contract "D". External functions have no internal entry point and can never be reached through "super". Declare "X.f" as public or reorder the inheritance hierarchy.
