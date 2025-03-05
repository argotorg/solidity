contract A {}
contract B {}
contract C is A, B is B{ }
// ----
// ParserError 6668: (47-49): More than one inheritance list.
