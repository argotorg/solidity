contract C {
    uint256[3] constant arr = [uint256(1), 2, 3];

    function get0() public pure returns (uint256) { return arr[0]; }
    function get1() public pure returns (uint256) { return arr[1]; }
    function get2() public pure returns (uint256) { return arr[2]; }
    function copyToMemory() public pure returns (uint256, uint256, uint256) {
        uint256[3] memory m = arr;
        return (m[0], m[1], m[2]);
    }
}
// ====
// compileViaYul: true
// ----
// get0() -> 1
// get1() -> 2
// get2() -> 3
// copyToMemory() -> 1, 2, 3
