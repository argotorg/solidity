contract C {
    function f() external payable returns (uint) { return 1; }
    function g() public {
        this.f{}();
    }
}
// ----
// ParserError 2314: (116-117): Expected ';' but got '{'
