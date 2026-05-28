contract A {
    modifier mod2(uint[] transient) { _; }
}
// ----
// Warning 6335: (31-47): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (31-47): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
