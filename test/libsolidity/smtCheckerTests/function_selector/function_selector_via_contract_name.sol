contract A {
    function f() external {}
    function g(uint256) external {}
}
contract B {
    function f() external returns (uint256) {}
    function g(uint256) external returns (uint256) {}
}
contract C {
    function test1() external pure returns(bytes4, bytes4, bytes4, bytes4) {
        return (A.f.selector, A.g.selector, B.f.selector, B.g.selector);
    }
    function test2() external pure returns(bytes4, bytes4, bytes4, bytes4) {
        A a; B b;
        return (a.f.selector, a.g.selector, b.f.selector, b.g.selector);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
