contract A {
    uint x;
    uint keccak256;
    function f() public pure returns (uint) {
        uint x = 1;
        return x;
    }
}
contract B is A {}
contract C is B {}
// ----
// Warning 2519: (99-105): This declaration shadows an existing declaration.
// Warning 2319: (29-43): This declaration shadows a builtin symbol.
