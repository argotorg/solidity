library L {
    type TLib is uint;
}

contract B {
    type TBase is uint;
}

contract C is B {
    type T is uint;

    function test() pure public {
        L.TLib;
        B.TBase;
        C.T;
    }
}
// ----
// Warning 6133: (159-165): Statement has no effect.
// Warning 6133: (175-182): Statement has no effect.
// Warning 6133: (192-195): Statement has no effect.
