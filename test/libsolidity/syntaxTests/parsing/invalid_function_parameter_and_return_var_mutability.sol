contract test {
    function f1(uint immutable a) public returns (uint immutable) { }
    function f2(uint constant a) public returns (uint constant) { }
}
// ----
// DeclarationError 8297: (32-48): The "immutable" keyword can only be used for state variables.
// DeclarationError 8297: (66-80): The "immutable" keyword can only be used for state variables.
// TypeError 6651: (102-117): Data location can only be specified for array, struct or mapping types, but "constant" was given.
// TypeError 6651: (135-148): Data location can only be specified for array, struct or mapping types, but "constant" was given.
