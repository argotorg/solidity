contract C
{
    struct Config { uint256 fee; address admin; }
    Config constant cfg = Config(42, address(0x1234));
    uint256[3] constant arr = [uint256(1), 2, 3];
    function f(Config constant c) internal pure returns (uint256) { return c.fee; }
}

// ----
