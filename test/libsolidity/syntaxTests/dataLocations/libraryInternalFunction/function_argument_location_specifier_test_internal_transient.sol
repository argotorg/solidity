library test {
    function f(bytes transient) internal pure {}
}
// ----
// Warning 6335: (30-45): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (30-45): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
