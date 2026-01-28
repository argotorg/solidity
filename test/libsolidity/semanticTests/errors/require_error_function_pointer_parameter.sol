error CustomError(function(uint256) external pure returns (uint256));

contract C
{
    function e(uint256 x) external pure returns (uint256)
    {
        return x;
    }

    function f() external view
    {
        // more than one stack slot
        require(false, CustomError(C(address(0x1234)).e));
    }
}

// ----
// f() -> FAILURE, hex"271b1dfa", hex"0000000000000000000000000000000000001234f37cdc8e0000000000000000"
