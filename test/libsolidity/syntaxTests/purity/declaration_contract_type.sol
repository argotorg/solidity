==== Source: a ====
contract A {}
library Lib {}
==== Source: b ====
import "a" as Mod;

library L {
    function f() public pure {
        Mod.A;
        Mod.Lib;
        L;
        C;
        C.f;
    }
}

contract C {
    function f() public pure {
        Mod.A;
        Mod.Lib;
        L;
        C;
        C.f;
    }
}
// ----
// Warning 6133: (b:71-76): Statement has no effect.
// Warning 6133: (b:86-93): Statement has no effect.
// Warning 6133: (b:103-104): Statement has no effect.
// Warning 6133: (b:114-115): Statement has no effect.
// Warning 6133: (b:125-128): Statement has no effect.
// Warning 6133: (b:191-196): Statement has no effect.
// Warning 6133: (b:206-213): Statement has no effect.
// Warning 6133: (b:223-224): Statement has no effect.
// Warning 6133: (b:234-235): Statement has no effect.
// Warning 6133: (b:245-248): Statement has no effect.
