contract C {
    function f() public pure returns (uint) {
        return erc7201(unicode"Hello 😃");
    }
}
// ----
