abstract contract A {
    function f() public view mod {
        require(block.timestamp > 10);
    }
    modifier mod() { }
}
// ----
// SyntaxError 2883: (121-124): Modifier body does not contain '_'.
