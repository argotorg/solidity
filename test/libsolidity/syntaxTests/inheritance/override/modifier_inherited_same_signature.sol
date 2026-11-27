contract A {
    modifier m() { _; }
    modifier n() { _; } // This extra modifier is here to detect regression (modifiers must be compared by name, not AST id)
}
contract B { modifier m() { _; } }
contract C is A,B {}
// ----
// TypeError 3412: (199-219): Two or more base classes define modifier with the same name: 'm'.
