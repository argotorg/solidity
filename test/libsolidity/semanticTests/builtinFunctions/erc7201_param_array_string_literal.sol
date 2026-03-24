contract C {
    function test() public pure returns (bool) {
        return erc7201(["x"][0]) == erc7201(["y", "x"][1]);
    }
}
// ----
// test() -> true
