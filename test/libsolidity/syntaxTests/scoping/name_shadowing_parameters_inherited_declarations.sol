contract A {
    uint x;
    function f() public pure {}
    modifier m() { _; }
    event E();
}

contract B is A {
    function g(uint x) public pure returns (uint f) {}
}

contract C is B {
    function h(int m) public pure returns (int E) {}
}
// ----
// Warning 2519: (132-138): This declaration shadows an existing declaration.
// Warning 2519: (161-167): This declaration shadows an existing declaration.
// Warning 2519: (208-213): This declaration shadows an existing declaration.
// Warning 2519: (236-241): This declaration shadows an existing declaration.
