contract C {
    function f() public pure returns (uint ret) {
        assembly {
            let clz := 1
            ret := clz
        }
    }
    function g() public pure returns (uint ret) {
        assembly {
            function clz() -> r {
                r := 1000
            }
            ret := clz()
        }
    }
}
// ====
// EVMVersion: <osaka
// ----
// f() -> 1
// g() -> 1000
