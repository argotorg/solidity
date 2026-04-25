contract C {
    struct Config {
        uint256 fee;
        address router;
        bytes32 tag;
    }

    Config constant cfg = Config(42, address(0x1234), bytes32("test"));

    function getFee() public pure returns (uint256) { return cfg.fee; }
    function getRouter() public pure returns (address) { return cfg.router; }
    function getTag() public pure returns (bytes32) { return cfg.tag; }
}
// ====
// compileViaYul: true
// ----
// getFee() -> 42
// getRouter() -> 0x0000000000000000000000000000000000001234
// getTag() -> 0x7465737400000000000000000000000000000000000000000000000000000000
