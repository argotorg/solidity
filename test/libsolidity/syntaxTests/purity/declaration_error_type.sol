==== Source: a ====
error ErrGlobalMod();

contract A {
    error ErrContractMod();
}
library LibMod {
    error ErrLibMod();
}
==== Source: b ====
import "a" as Mod;

error ErrGlobal();

library Lib {
    error ErrLib();
}

contract C {
    error ErrContract();

    function f() public pure {
        Mod.ErrGlobalMod;
        Mod.A.ErrContractMod;
        Mod.LibMod.ErrLibMod;
        C.ErrContract;
        Lib.ErrLib;
        // FIXME: These two should generate warnings too.
        ErrGlobal;
        ErrContract;
    }
}
// ----
// Warning 6133: (b:155-171): Statement has no effect.
// Warning 6133: (b:181-201): Statement has no effect.
// Warning 6133: (b:211-231): Statement has no effect.
// Warning 6133: (b:241-254): Statement has no effect.
// Warning 6133: (b:264-274): Statement has no effect.
