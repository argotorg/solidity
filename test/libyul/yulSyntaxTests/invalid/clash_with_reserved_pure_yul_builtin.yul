{
    // NOTE: These are builtins but only in pure Yul, not inline assembly.
    // NOTE: Names of these builtins are also reserved identifiers.
    function loadimmutable(setimmutable) -> datasize {}
    let dataoffset
}
// ====
// bytecodeFormat: legacy
// ----
// ParserError 5568: (158-171): Cannot use builtin function name "loadimmutable" as identifier name.
// ParserError 5568: (172-184): Cannot use builtin function name "setimmutable" as identifier name.
// ParserError 5568: (189-197): Cannot use builtin function name "datasize" as identifier name.
// ParserError 5568: (209-219): Cannot use builtin function name "dataoffset" as identifier name.
