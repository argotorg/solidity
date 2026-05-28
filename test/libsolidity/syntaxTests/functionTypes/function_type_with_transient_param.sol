contract C {
    function (uint transient) external y;
    function (uint[] transient) external z;
}
// ----
// Warning 6162: (27-41): Naming function type parameters is deprecated.
// Warning 6162: (69-85): Naming function type parameters is deprecated.
// Warning 6335: (27-41): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (69-85): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (69-85): Data location must be "memory" or "calldata" for parameter in function, but none was given.
