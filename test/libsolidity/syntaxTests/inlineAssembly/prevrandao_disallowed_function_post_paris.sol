contract C {
    function f() public view returns (uint256 ret) {
        assembly {
            let prevrandao := sload(0)
            ret := prevrandao
        }
    }

    function g() public pure returns (uint256 ret) {
        assembly {
            function prevrandao() -> r {
                r := 1000
            }
            ret := prevrandao()
        }
    }
}
// ====
// EVMVersion: >=paris
// ----
// ParserError 5568: (101-111): Cannot use builtin function name "prevrandao" as identifier name.
// ParserError 7104: (143-153): Builtin function "prevrandao" must be called.
