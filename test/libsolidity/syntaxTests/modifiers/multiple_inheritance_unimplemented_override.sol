contract A {
    modifier m() virtual { _; }
}
abstract contract B {
    modifier m() virtual;
}
contract C is A, B {
    modifier m() override(A, B) { _; }
    function f() m public {}
}
// ----
// Warning 8429: (17-44): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (73-94): Virtual modifiers are deprecated and scheduled for removal.
