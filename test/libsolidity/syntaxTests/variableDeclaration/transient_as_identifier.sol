contract C {
    function transient() public pure { }
}

error CustomError(uint transient);
event e1(uint transient);
event e2(uint indexed transient);

struct S {
    int transient;
}

contract D {
    function f() public pure returns (uint) {
        uint transient = 1;
        return transient;
    }

    function g(int transient) public pure { }

    modifier m(address transient) {
        _;
    }
}
// ----
// Warning 6335: (17-53): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (75-89): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (101-115): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (127-149): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (168-181): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (253-267): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (321-334): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (368-385): "transient" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
