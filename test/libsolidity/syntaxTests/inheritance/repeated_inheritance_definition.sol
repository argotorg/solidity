contract A {}
contract B {}
contract C is A is B is B is A{ }
// ----
// ParserError 6668: (44-46): More than one inheritance list.
// ParserError 6668: (49-51): More than one inheritance list.
// ParserError 6668: (54-56): More than one inheritance list.
