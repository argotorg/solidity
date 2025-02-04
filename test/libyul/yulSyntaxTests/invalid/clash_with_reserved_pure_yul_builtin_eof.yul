{
    // NOTE: These are builtins but only in pure Yul, not inline assembly.
    // NOTE: Names of these builtins are also reserved identifiers.
    function auxdataloadn(eofcreate) -> returncontract {}
    let eofcreate
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// ParserError 5568: (158-170): Cannot use builtin function name "auxdataloadn" as identifier name.
// ParserError 5568: (171-180): Cannot use builtin function name "eofcreate" as identifier name.
// ParserError 5568: (185-199): Cannot use builtin function name "returncontract" as identifier name.
// ParserError 5568: (211-220): Cannot use builtin function name "eofcreate" as identifier name.
