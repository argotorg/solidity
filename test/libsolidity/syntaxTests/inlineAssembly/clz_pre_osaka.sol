contract C {
    function f(uint256 x) public pure returns (bytes32 ret) {
        assembly {
            ret := clz(x)
        }
    }
}
// ====
// EVMVersion: =prague
// ----
// TypeError 4948: (113-116): The "clz" instruction is only available for Osaka-compatible VMs (you are currently compiling for "prague").
// DeclarationError 8678: (106-119): Variable count for assignment to "ret" does not match number of values (1 vs. 0)
