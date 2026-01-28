contract C {
    function f() public view returns (uint ret) {
        assembly {
            let tstore := sload(0)
            ret := tstore
        }
    }
}
// ====
// EVMVersion: >=cancun
// ----
// ParserError 5568: (98-104): Cannot use builtin function name "tstore" as identifier name.
// ParserError 7104: (136-142): Builtin function "tstore" must be called.
