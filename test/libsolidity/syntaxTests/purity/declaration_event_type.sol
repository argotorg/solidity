==== Source: a ====
event EvGlobalMod();

contract A {
    event EvContractMod();
}
library LibMod {
    event EvLibMod();
}
==== Source: b ====
import "a" as Mod;

event EvGlobal();

library Lib {
    event EvLib();
}

contract C {
    event EvContract();

    function f() public pure {
        Mod.EvGlobalMod;
        Mod.A.EvContractMod;
        Mod.LibMod.EvLibMod;
        C.EvContract;
        Lib.EvLib;
        // FIXME: These two should generate warnings too.
        EvGlobal;
        EvContract;
    }
}
// ----
// Warning 6133: (b:152-167): Statement has no effect.
// Warning 6133: (b:177-196): Statement has no effect.
// Warning 6133: (b:206-225): Statement has no effect.
// Warning 6133: (b:235-247): Statement has no effect.
// Warning 6133: (b:257-266): Statement has no effect.
