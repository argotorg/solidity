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
        require(false, CustomError(this.e));
    }
}

// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f() -> FAILURE, hex"271b1dfa", hex"a4dc3b5fce39438ce512c732ccb22e3212856bb6f37cdc8e0000000000000000"
