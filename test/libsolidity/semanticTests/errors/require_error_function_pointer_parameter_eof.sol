error CustomError(function(uint256) external pure returns (uint256));

contract C
{
    function f(function(uint256) external pure returns (uint256) x) external view
    {
        // more than one stack slot
        require(false, CustomError(x));
    }
}

// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f(function): left(0xa4dc3b5fce39438ce512c732ccb22e3212856bb6f37cdc8e0000000000000000) -> FAILURE, hex"271b1dfa", hex"a4dc3b5fce39438ce512c732ccb22e3212856bb6f37cdc8e0000000000000000"
