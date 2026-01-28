object "a" {
    code {
        function extdelegatecall() {}
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// ParserError 5568: (41-56): Cannot use builtin function name "extdelegatecall" as identifier name.
