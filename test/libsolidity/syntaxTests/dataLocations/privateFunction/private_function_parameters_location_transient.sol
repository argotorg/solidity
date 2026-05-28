contract C {
    function f(uint[] transient) private pure {}
}
// ----
// Warning 6335: (28-44): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (28-44): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
