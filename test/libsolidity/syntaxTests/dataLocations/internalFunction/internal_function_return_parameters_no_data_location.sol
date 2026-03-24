contract C {
    function g() internal pure returns(uint[]) {}
}
// ----
// TypeError 6651: (52-58): Data location must be "storage", "memory", "calldata" or "constant" for return parameter in function, but none was given.
