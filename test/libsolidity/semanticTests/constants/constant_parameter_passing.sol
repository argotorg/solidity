contract C {
    struct Config { uint256 fee; address admin; }
    Config constant CFG = Config(42, address(0xdead));
    uint256[3] constant ARR = [uint256(1), 2, 3];

    function readFee(Config constant cfg) internal pure returns (uint256) {
        return cfg.fee;
    }
    function sumArr(uint256[3] constant a) internal pure returns (uint256) {
        return a[0] + a[1] + a[2];
    }

    function testConfig() public pure returns (uint256) { return readFee(CFG); }
    function testArr() public pure returns (uint256) { return sumArr(ARR); }
}
// ====
// compileViaYul: true
// ----
// testConfig() -> 42
// testArr() -> 6
