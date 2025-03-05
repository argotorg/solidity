contract C {
    function f() public pure layout at 32 { }
}
// ----
// ParserError 2314: (52-54): Expected '{' but got 'Number'
