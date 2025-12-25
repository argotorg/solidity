contract A {
    modifier f() virtual { _; }
}
contract B {
    modifier f() virtual { _; }
}
contract C is A, B {
}
// ----
// Warning 8429: (17-44): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (64-91): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 6480: (94-116): Derived contract must override modifier "f". Two or more base classes define modifier with same name.
