library L {
    uint constant vLib = 1;
}

contract B {
    uint constant vBase = 1;
}

contract C is B {
    uint256 constant a = L.vLib;
    uint256 constant v = C.a;
    uint256 constant vBaseCopy = B.vBase;

    function test() pure public {
        L.vLib;
        C.v;
        B.vBase;
    }
}
// ----
// Warning 6133: (254-260): Statement has no effect.
// Warning 6133: (270-273): Statement has no effect.
// Warning 6133: (283-290): Statement has no effect.
