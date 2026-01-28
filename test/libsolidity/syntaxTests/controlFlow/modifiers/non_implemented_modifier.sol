abstract contract A {
    function f() public view mod {
        require(block.timestamp > 10);
    }
    modifier mod() virtual;
}
// ----
// Warning 8429: (106-129): Virtual modifiers are deprecated and scheduled for removal.
