contract C {
    enum Color { Red, Green, Blue }

    Color[3] constant colors = [Color.Red, Color.Green, Color.Blue];

    function get(uint256 i) public pure returns (Color) { return colors[i]; }
}
// ====
// compileViaYul: true
// ----
// get(uint256): 0 -> 0
// get(uint256): 1 -> 1
// get(uint256): 2 -> 2
