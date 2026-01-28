contract C {
    function f(uint256 x) public pure returns (bytes32 ret) {
        assembly {
            ret := clz(x)
        }
    }
}
// ====
// EVMVersion: >=osaka
// ----
