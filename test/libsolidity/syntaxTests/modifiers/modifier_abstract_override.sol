contract A {
    modifier m() virtual { _; }
}
abstract contract B is A {
    modifier m() virtual override;
}
contract C is B {
    function f() m public {}
}
// ----
// Warning 8429: (17-44): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (78-108): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 4593: (78-108): Overriding an implemented modifier with an unimplemented modifier is not allowed.
