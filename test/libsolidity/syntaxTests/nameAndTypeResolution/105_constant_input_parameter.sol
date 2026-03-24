contract test {
    function f(uint[] memory constant a) public { }
}
// ----
// ParserError 3548: (45-53): Location already specified.
