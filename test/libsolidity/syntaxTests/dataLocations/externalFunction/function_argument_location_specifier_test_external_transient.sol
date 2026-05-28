contract test {
    function f(bytes transient) external;
}
// ----
// Warning 6335: (31-46): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (31-46): Data location must be "memory" or "calldata" for parameter in external function, but none was given.
