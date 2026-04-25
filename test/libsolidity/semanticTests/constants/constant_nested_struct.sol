contract C {
    struct Inner { uint256 a; uint256 b; }
    struct Outer { Inner inner; uint256 c; }

    Outer constant nested = Outer(Inner(10, 20), 30);

    function getInnerA() public pure returns (uint256) { return nested.inner.a; }
    function getInnerB() public pure returns (uint256) { return nested.inner.b; }
    function getC() public pure returns (uint256) { return nested.c; }
}
// ====
// compileViaYul: true
// ----
// getInnerA() -> 10
// getInnerB() -> 20
// getC() -> 30
