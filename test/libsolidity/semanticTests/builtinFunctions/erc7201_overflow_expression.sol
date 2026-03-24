contract C {
    function f() public pure returns (uint) {
        return erc7201("main:example") + erc7201("main:example");
    }
}
// ----
// f() -> FAILURE, hex"4e487b71", 0x11
