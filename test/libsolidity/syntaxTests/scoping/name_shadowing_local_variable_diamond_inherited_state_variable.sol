contract A {
    uint x;
    uint keccak256;
}
contract B is A {}
contract C is A {}
contract D is B, C {
    function f() public pure returns (uint) {
        uint x = 1;
        return x;
    }
}
// ----
// Warning 2319: (29-43): This declaration shadows a builtin symbol.
// Warning 2519: (160-166): This declaration shadows an existing declaration.
