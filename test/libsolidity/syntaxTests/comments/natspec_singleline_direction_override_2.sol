contract C {
    /// bad ‮
    function f() public pure {}
}
// ----
// ParserError 1109: (17-33): Mismatching directional override markers in comment or string literal.
