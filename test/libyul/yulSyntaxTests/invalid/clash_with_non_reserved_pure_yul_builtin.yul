{
    { function memoryguard() {} }
    { function f(memoryguard) {} }
    { function f() -> memoryguard {} }
    { let memoryguard }
}
// ----
// ParserError 5568: (17-28): Cannot use builtin function name "memoryguard" as identifier name.
// ParserError 5568: (53-64): Cannot use builtin function name "memoryguard" as identifier name.
// ParserError 5568: (93-104): Cannot use builtin function name "memoryguard" as identifier name.
// ParserError 5568: (120-131): Cannot use builtin function name "memoryguard" as identifier name.
