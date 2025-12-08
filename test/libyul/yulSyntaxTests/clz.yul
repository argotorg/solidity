{
    {
        let clz := 1
    }

    {
        function clz() {}
        clz()
    }
}

// ====
// EVMVersion: >=osaka
// ----
// ParserError 5568: (20-23): Cannot use builtin function name "clz" as identifier name.
// ParserError 5568: (59-62): Cannot use builtin function name "clz" as identifier name.
