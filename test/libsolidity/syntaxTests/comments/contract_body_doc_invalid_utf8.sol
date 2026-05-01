contract C {
    /// inside÷ doc
    function f() public {}
}
// ----
// ParserError 5100: (17-37): Invalid UTF-8 sequence in documentation comment.
