library L {
    event Ev();
}

contract Ext {
    event Ev();
}

contract C {
    event Ev();
    function test() pure public {
        L.Ev;
        Ext.Ev;
        C.Ev;
    }
}
// ----
// Warning 6133: (136-140): Statement has no effect.
// Warning 6133: (150-156): Statement has no effect.
// Warning 6133: (166-170): Statement has no effect.
