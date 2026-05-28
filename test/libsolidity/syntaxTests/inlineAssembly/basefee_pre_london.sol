contract C {
    function f() public view returns (uint ret) {
        assembly {
            let basefee := sload(0)
            ret := basefee
        }
    }
}
// ====
// EVMVersion: <=berlin
// ----
// Warning 5470: (98-105): "basefee" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
