abstract contract A {
    modifier m() virtual;
    function f() m public {}
}
contract B is A {
    modifier m() virtual override { _; }
}
// ----
// Warning 8429: (26-47): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (101-137): Virtual modifiers are deprecated and scheduled for removal.
