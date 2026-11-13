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
