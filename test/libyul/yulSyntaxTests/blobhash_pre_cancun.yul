{
    {
        let blobhash := 1
    }

    {
        function blobhash() {}
        blobhash()
    }
}
// ====
// EVMVersion: <=shanghai
// ----
// Warning 5470: (20-28): "blobhash" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (55-77): "blobhash" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
