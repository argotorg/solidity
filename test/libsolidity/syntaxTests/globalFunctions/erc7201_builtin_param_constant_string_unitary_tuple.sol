contract C {
    string constant const = ("x");
    function constArg() public pure returns (uint) {
        return erc7201(const);
    }
}
// ----
