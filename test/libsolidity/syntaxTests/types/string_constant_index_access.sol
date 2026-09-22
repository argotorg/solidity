contract Test {
    string constant x = "abefghijklmnopqabcdefghijklmnopqabcdefghijklmnopqabca";
    function f() public pure {
        x[0];
    }
}
// ----
// TypeError 9961: (136-140): Index access for string is not possible.
