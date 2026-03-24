contract A {
    modifier mod1(uint constant a) { _; }
    modifier mod2(uint immutable a) { _; }
}
// ----
// TypeError 6651: (31-46): Data location can only be specified for array, struct or mapping types, but "constant" was given.
// DeclarationError 8297: (73-89): The "immutable" keyword can only be used for state variables.
