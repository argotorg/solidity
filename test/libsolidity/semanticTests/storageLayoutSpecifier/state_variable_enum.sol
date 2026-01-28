enum Color {Red, Blue, Green }
contract C layout at 42 {
    Color c;
    function cSlotOffset() public returns(uint s, uint o) {
        assembly { s := c.slot o := c.offset }
    }
    function setBlue() public {
        c = Color.Blue;
    }
    function checkBlue() public view returns (bool) {
        return c == Color.Blue;
    }
}
// ----
// cSlotOffset() -> 42, 0
// checkBlue() -> false
// setBlue() ->
// checkBlue() -> true
