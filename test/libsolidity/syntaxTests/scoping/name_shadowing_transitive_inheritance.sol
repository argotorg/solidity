contract A {
    uint256 value = 10;
}
contract B is A {}
contract C is B {
    function f() public pure returns (uint256) {
        uint256 value = 99;
        return value;
    }
}
// ----
// Warning 2519: (133-146): This declaration shadows an existing declaration.
