contract A {
    modifier f(uint a) { _; }
}
contract B {
    modifier f() { _; }
}
contract C is A, B {
}
// ----
// TypeError 3412: (84-106): Two or more base classes define modifier with the same name: 'f'.
