library L {
    enum E { V }
}

contract Ext {
    enum E { V }
}

contract C {
    enum E { V }

    function test() pure public {
        L.E;
        Ext.E;
        C.E;
    }
}
// ----
// Warning 6133: (140-143): Statement has no effect.
// Warning 6133: (153-158): Statement has no effect.
// Warning 6133: (168-171): Statement has no effect.
