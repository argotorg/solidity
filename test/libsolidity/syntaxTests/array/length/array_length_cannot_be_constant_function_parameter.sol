contract C {
    function f(uint constant LEN) public {
        uint[LEN] a;
    }
}
// ----
// TypeError 6651: (28-45): Data location can only be specified for array, struct or mapping types, but "constant" was given.
// TypeError 5462: (69-72): Invalid array length, expected integer literal or constant expression.
// TypeError 6651: (64-75): Data location must be "storage", "memory" or "calldata" for variable, but none was given.
