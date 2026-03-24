contract C {
    struct Config {
        uint256[3] fees;
        address admin;
    }
    Config constant CFG = Config([uint256(100), 200, 300], address(0xdead));

    function getFee(uint256 i) public pure returns (uint256) { return CFG.fees[i]; }
    function getAdmin() public pure returns (address) { return CFG.admin; }
}
// ====
// compileViaYul: true
// ----
// getFee(uint256): 0 -> 100
// getFee(uint256): 1 -> 200
// getFee(uint256): 2 -> 300
// getAdmin() -> 0x000000000000000000000000000000000000dead
