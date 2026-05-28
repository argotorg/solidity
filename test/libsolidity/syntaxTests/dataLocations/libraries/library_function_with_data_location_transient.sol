library L {
    function f1(uint[] transient) private pure { }
    function f2() private pure returns (uint[] transient) { }
    function g1(uint[] transient) internal pure { }
    function g2() internal pure returns (uint[] transient) { }
    function h1(uint[] transient) public pure { }
    function h2() public pure returns (uint[] transient) { }
    function i1(uint[] transient) external pure { }
    function i2() external pure returns (uint[] transient) { }
}
// ----
// Warning 6335: (28-44): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (103-119): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (141-157): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (218-234): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (256-272): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (329-345): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (367-383): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (444-460): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// TypeError 6651: (28-44): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
// TypeError 6651: (103-119): Data location must be "storage", "memory" or "calldata" for return parameter in function, but none was given.
// TypeError 6651: (141-157): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
// TypeError 6651: (218-234): Data location must be "storage", "memory" or "calldata" for return parameter in function, but none was given.
// TypeError 6651: (256-272): Data location must be "storage", "memory" or "calldata" for parameter in function, but none was given.
// TypeError 6651: (329-345): Data location must be "storage", "memory" or "calldata" for return parameter in function, but none was given.
// TypeError 6651: (367-383): Data location must be "storage", "memory" or "calldata" for parameter in external function, but none was given.
// TypeError 6651: (444-460): Data location must be "storage", "memory" or "calldata" for return parameter in function, but none was given.
