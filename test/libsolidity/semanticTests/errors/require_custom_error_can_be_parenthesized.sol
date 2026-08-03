// This could be a syntax test, but we want to check compilation with --via-ir as well.
contract C {
    error MyError(uint256);
    function f() public pure returns (uint256)
    {
        require(false, (MyError(1)));
        return 42;
    }
}
// ----
// f() -> FAILURE, hex"30b1b565", 1
