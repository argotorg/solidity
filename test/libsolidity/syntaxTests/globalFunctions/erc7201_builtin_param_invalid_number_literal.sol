contract C {
    function f() public pure returns (uint) {
        return erc7201(123);
    }
}
// ----
// TypeError 6896: (82-85): The argument to erc7201 builtin must be a string.
// TypeError 9553: (82-85): Invalid type for argument in function call. Invalid implicit conversion from int_const 123 to string memory requested.
