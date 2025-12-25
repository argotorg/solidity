contract Counter {
    uint256 public constant MIN_LIQUIDITY = 1000;

    function run() view public {
        this.MIN_LIQUIDITY();
    }
}
// ----
