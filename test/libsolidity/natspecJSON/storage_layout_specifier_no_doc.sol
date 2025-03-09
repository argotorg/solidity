contract C
    /// @notice this changes the base slot of the contract storage
    layout at
    /// @dev the expression must be in range of uint256
    0x1234
{ }
// ====
// stopAfter: analysis
// ----
// ----
// :C devdoc
// {
//     "kind": "dev",
//     "methods": {},
//     "version": 1
// }
//
// :C userdoc
// {
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
