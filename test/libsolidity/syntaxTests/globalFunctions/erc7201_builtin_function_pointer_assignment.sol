contract C {
    function (string memory) pure returns (uint256) functionPointer;
    function f() public pure {
        functionPointer = erc7201;
    }
}
// ----
// TypeError 7407: (139-146): Type function (string memory) pure returns (uint256) is not implicitly convertible to expected type function (string memory) pure returns (uint256). Special functions cannot be converted to function types.
