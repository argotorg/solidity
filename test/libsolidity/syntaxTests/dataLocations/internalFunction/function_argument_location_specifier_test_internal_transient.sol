contract test {
    function f(bytes transient) internal {}
}
// ----
// Warning 6335: (31-46): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (31-46): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
