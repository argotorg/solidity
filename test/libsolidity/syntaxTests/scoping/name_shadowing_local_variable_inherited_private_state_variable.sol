contract A {
    uint256 private x;
}
contract B is A {
    function f() public pure returns (uint256) {
        uint256 x = 99;
        return x;
    }
}
