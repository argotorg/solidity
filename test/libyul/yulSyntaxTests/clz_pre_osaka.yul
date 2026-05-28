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
// EVMVersion: <osaka
// ----
// Warning 5470: (20-23): "clz" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (50-67): "clz" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
