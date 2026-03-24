contract C {
    function f() public pure returns (uint) {
        return erc7201("\tstring with spaces\n\r");
    }
}
// ----
