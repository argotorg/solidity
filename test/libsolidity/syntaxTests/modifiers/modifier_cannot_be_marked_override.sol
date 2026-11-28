contract C {
    modifier m() override {_;}
}
// ----
// ParserError 2785: (30-38): Modifiers cannot be marked 'virtual' or 'override'. Virtual modifiers have been removed.
