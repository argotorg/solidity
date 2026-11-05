contract C {
    modifier m() override {_;}
}
// ----
// ParserError 2314: (30-38): Expected '{' but got 'override'
