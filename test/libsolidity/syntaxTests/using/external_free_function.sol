// Used to cause ICE in FunctionDefinition::type() when an external free
// function (already a syntax error) was bound via `using for`.
function f(int) external;
using {f} for int global;
// ----
// SyntaxError 4126: (0-26): Free functions cannot have visibility.
// TypeError 4668: (0-26): Free functions must be implemented.
