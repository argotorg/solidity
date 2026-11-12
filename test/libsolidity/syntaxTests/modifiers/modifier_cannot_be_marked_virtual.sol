contract C {
    modifier m() virtual {_;}
}
// ----
// ParserError 2785: (30-37): Modifiers cannot be marked 'virtual' or 'override'. Virtual modifiers have been removed.
