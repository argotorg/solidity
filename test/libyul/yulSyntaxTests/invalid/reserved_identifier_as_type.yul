{
    let x: jump
    x := true: dup12

    function f(y: jumpi) {}
}
// ----
// ParserError 5473: (10-17): Types are not supported in untyped Yul.
// ParserError 5473: (27-38): Types are not supported in untyped Yul.
// ParserError 5473: (55-63): Types are not supported in untyped Yul.
