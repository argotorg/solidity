bytes constant bytesArg = "abcdef";
contract C {
    function f() public pure returns (uint256) {
        return erc7201(bytesArg);
    }
}
// ----
// TypeError 6896: (121-129): The argument to erc7201 builtin must be a string. The supplied argument has type bytes.
// TypeError 9553: (121-129): Invalid type for argument in function call. Invalid implicit conversion from bytes memory to string memory requested.
