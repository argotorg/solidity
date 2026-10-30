contract C {
    modifier m() virtual {_;}
}
// ----
// ParserError 2314: (30-37): Expected '{' but got 'virtual'
