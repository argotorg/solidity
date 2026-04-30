contract C {
    function f() public pure {
        bytes.concat({x: "abc"});
    }
}
// ----
// TypeError 7101: (52-76): Named arguments cannot be used for the bytes.concat function call.
