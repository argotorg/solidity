pragma experimental solidity;

forall (A, B)
class Self: C {}
// ====
// experimental: true
// EVMVersion: >=constantinople
// ----
// ParserError 5709: (45-50): Expected a function definition.
