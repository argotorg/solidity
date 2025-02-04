{
    let x: memoryguard
    x := true: linkersymbol

    function f(y: linkersymbol) {}
}
// ----
// ParserError 5568: (13-24): Cannot use builtin function name "memoryguard" as identifier name.
// ParserError 5473: (10-24): Types are not supported in untyped Yul.
// ParserError 5568: (40-52): Cannot use builtin function name "linkersymbol" as identifier name.
// ParserError 5473: (34-52): Types are not supported in untyped Yul.
// ParserError 5568: (72-84): Cannot use builtin function name "linkersymbol" as identifier name.
// ParserError 5473: (69-84): Types are not supported in untyped Yul.
