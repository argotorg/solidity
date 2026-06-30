contract C {
    function f() public view returns (bytes32 ret) {
        assembly {
            ret := clz(0)
        }
    }

    function g() public view returns (bytes32 ret) {
        assembly {
            ret := clz(1)
        }
    }

    function h() public view returns (bytes32 ret) {
        assembly {
            ret := clz(0x4000000000000000000000000000000000000000000000000000000000000000)
        }
    }
}
// ====
// EVMVersion: >=osaka
// ----
// f() -> 0x0100
// g() -> 0xff
// h() -> 0x01
