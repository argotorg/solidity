{
    // NOTE: All EVM instruction names are reserved identifiers in Yul.
    // NOTE: We do provide builtins corresponding to these instructions.
    function add(mstore) -> sstore {}
    let coinbase
}
// ----
// ParserError 5568: (160-163): Cannot use builtin function name "add" as identifier name.
// ParserError 5568: (164-170): Cannot use builtin function name "mstore" as identifier name.
// ParserError 5568: (175-181): Cannot use builtin function name "sstore" as identifier name.
// ParserError 5568: (193-201): Cannot use builtin function name "coinbase" as identifier name.
