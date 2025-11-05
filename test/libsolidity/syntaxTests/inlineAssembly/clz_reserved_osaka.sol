contract C {
    function f() public pure returns (uint ret) {
        assembly {
            function clz() -> r {
                r := 1000
            }
            ret := clz()
        }
    }
}
// ====
// EVMVersion: >=osaka
// ----
// ParserError 5568: (103-106): Cannot use builtin function name "clz" as identifier name.
