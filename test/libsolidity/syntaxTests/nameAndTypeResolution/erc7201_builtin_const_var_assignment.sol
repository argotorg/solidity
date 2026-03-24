contract C {
    uint constant x = erc7201("abc");
    function f() public pure returns(uint) {
        return mulmod(x, 10, 37);
    }
}
// ----
