contract C {
    function g(uint[]) internal pure {}
}
// ----
// TypeError 6651: (28-34): Data location must be "storage", "memory", "calldata" or "constant" for parameter in function, but none was given.
