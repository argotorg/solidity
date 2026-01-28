contract Counter {
    uint256 public immutable MIN_LIQUIDITY = 1000;

    function run() view public {
        this.MIN_LIQUIDITY();
    }
}
// ----
