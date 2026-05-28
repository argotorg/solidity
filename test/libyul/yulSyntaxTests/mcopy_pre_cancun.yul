{
    {
        let mcopy := 1
    }

    {
        function mcopy() {}
        mcopy()
    }
}
// ====
// EVMVersion: <cancun
// ----
// Warning 5470: (20-25): "mcopy" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (52-71): "mcopy" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
