contract Foo {
    function f(uint[] storage constant x, uint[] memory y) internal { }
}
// ----
// ParserError 3548: (45-53): Location already specified.
