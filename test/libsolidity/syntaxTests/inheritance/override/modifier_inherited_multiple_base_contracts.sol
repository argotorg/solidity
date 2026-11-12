contract A { modifier m() { _; } }
contract B { modifier m() { _; } }
contract C { modifier m() { _; } }
contract D is A,B,C {}
// ----
// TypeError 3412: (105-127): Two or more base classes define modifier with the same name: 'm'.
