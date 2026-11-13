contract A {
    uint256 internal x;
    function g() internal pure {}
    modifier m() { _; }
    event E();
}
contract B is A {
    function f(uint256 x) public pure returns (uint256 g) {}
    function h(uint256 m) public pure returns (uint256 E) {}
}
// ----
// Warning 2519: (145-154): This declaration shadows an existing declaration.
// Warning 2519: (177-186): This declaration shadows an existing declaration.
// Warning 2519: (206-215): This declaration shadows an existing declaration.
// Warning 2519: (238-247): This declaration shadows an existing declaration.
