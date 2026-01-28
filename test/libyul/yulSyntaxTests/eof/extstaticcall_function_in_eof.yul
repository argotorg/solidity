object "a" {
    code {
        function extstaticcall() {}
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// ParserError 5568: (41-54): Cannot use builtin function name "extstaticcall" as identifier name.
