contract C {
    error E(uint256);

    uint counter = 0;

    function even() internal returns (bool) {
        return counter % 2 == 0;
    }

    function inc() internal returns (uint256) {
        return ++counter;
    }

    function flip() public {
        require(even(), E(inc()));
    }
}
// ====
// revertStrings: strip
// ----
// flip() ->
// flip() -> FAILURE, hex"002ff067", 2
