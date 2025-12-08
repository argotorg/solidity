abstract contract A {
    function f() public view mod {
        require(block.timestamp > 10);
    }
    modifier mod() virtual { }
}
// ----
// SyntaxError 2883: (129-132): Modifier body does not contain '_'.
// Warning 8429: (106-132): Virtual modifiers are deprecated and scheduled for removal.
