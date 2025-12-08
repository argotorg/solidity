contract A {
    modifier f(uint a) virtual { _; }
}
contract B {
    modifier f() virtual { _; }
}
contract C is A, B {
    modifier f() virtual override(A, B) { _; }
}
// ----
// Warning 8429: (17-50): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (70-97): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (125-167): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 1078: (125-167): Override changes modifier signature.
