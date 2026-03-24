pragma experimental solidity;

contract C {}

// ====
// experimental: true
// EVMVersion: <constantinople
// ----
// ParserError 7637: (31-39): Experimental solidity requires Constantinople EVM version at the minimum.
