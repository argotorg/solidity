contract A {
    uint x;
    function f() public pure returns (uint) {
        uint x = 1;
        return x;
    }
}
contract B is A {
    function g() public pure returns (uint) {
        uint x = y;
        return x;
    }
}
// ----
// DeclarationError 7576: (198-199): Undeclared identifier.
// Warning 2519: (79-85): This declaration shadows an existing declaration.
// Warning 2519: (189-195): This declaration shadows an existing declaration.
