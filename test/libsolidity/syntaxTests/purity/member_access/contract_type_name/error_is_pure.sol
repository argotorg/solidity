library L {
    error Err();
}

contract Ext {
    error Err();
}

contract C {
    error Err();

    function test() pure public {
        L.Err;
        Ext.Err;
        C.Err;
    }
}
// ----
// Warning 6133: (140-145): Statement has no effect.
// Warning 6133: (155-162): Statement has no effect.
// Warning 6133: (172-177): Statement has no effect.
