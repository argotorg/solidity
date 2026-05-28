contract C {
    function f() private pure returns (uint[] transient) {}
}
// ----
// Warning 6335: (52-68): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (52-68): Data location must be "storage", "memory" or "calldata" for return parameter in function, but none was given.
