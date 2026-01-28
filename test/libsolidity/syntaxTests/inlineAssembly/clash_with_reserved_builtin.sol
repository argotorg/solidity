contract C {
    function f() public view {
        assembly {
            // NOTE: All EVM instruction names are reserved identifiers in Yul.
            // NOTE: We do provide builtins corresponding to these instructions.
            function add(mstore) -> sstore {}
            let coinbase
        }
    }
}
// ----
// ParserError 5568: (245-248): Cannot use builtin function name "add" as identifier name.
// ParserError 5568: (249-255): Cannot use builtin function name "mstore" as identifier name.
// ParserError 5568: (260-266): Cannot use builtin function name "sstore" as identifier name.
// ParserError 5568: (286-294): Cannot use builtin function name "coinbase" as identifier name.
