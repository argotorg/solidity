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
// EVMVersion: <paris
// ----
// Warning 5470: (101-111): "prevrandao" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (255-323): "prevrandao" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
