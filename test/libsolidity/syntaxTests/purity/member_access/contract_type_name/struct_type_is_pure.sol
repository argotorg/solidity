contract Ext {
    struct S { uint256 v; }
}

contract C {
    struct S { uint256 v; }

    function test() pure public {
        C.S;
        Ext.S;
    }
}
// ----
// Warning 6133: (130-133): Statement has no effect.
// Warning 6133: (143-148): Statement has no effect.
