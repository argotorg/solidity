abstract contract A { uint256 public x = 1; }
abstract contract B is A {}
contract C is B {
    function f() public pure returns (uint256) {
        uint256 x = 99;
        return x;
    }
}
// ----
// Warning 2519: (149-158): This declaration shadows an existing declaration.
