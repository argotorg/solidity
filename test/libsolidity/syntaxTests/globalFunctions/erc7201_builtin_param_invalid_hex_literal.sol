contract C {
    function f() public pure returns (uint) {
        return erc7201(hex"001122FF");
    }
}
// ----
// TypeError 9553: (82-95): Invalid type for argument in function call. Invalid implicit conversion from literal_string hex"001122ff" to string memory requested. Contains invalid UTF-8 sequence at position 3.
