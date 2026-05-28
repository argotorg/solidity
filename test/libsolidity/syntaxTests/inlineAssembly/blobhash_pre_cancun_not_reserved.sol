contract C {
    function f() public pure returns (uint ret) {
        assembly {
            let blobhash := 1
            ret := blobhash
        }
    }
    function g() public pure returns (uint ret) {
        assembly {
            function blobhash() -> r {
                r := 1000
            }
            ret := blobhash()
        }
    }
}
// ====
// EVMVersion: <=shanghai
// ----
// Warning 5470: (98-106): "blobhash" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (237-303): "blobhash" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
