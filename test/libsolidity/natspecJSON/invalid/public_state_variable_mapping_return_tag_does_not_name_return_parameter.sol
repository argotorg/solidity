contract C {
    /// @return wrong amount
    mapping(uint => uint val) public m;
}
// ----
// DocstringParsingError 5856: (17-41): Documentation tag "@return wrong amount" does not contain the name of its return parameter.
