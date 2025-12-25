abstract contract A {
    modifier m() virtual;
}
abstract contract B is A {
    modifier m() virtual override;
}
abstract contract C is B {
    modifier m() virtual override;
    function f() m public {}
}
// ----
// Warning 8429: (26-47): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (81-111): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (145-175): Virtual modifiers are deprecated and scheduled for removal.
