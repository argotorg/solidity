contract C {
    function f() public pure {
        string.concat({x: "abc"});
    }
}
// ----
// TypeError 7173: (52-77): Named arguments cannot be used for the string.concat function call.
