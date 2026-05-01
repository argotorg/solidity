contract C {}
/// invalid utf-8: ÷
// ----
// ParserError 5985: (14-35): Invalid UTF-8 sequence in documentation comment.
