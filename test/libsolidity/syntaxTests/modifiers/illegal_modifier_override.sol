contract A { modifier mod(uint a) { _; } }
contract B is A { modifier mod(uint8 a) { _; } }
// ----
// TypeError 5827: (61-89): Cannot override modifiers.
