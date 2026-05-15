==== Source: a ====
enum A { Red, Blue }

library ALib {
    enum LibraryEnum { Red, Blue }
}

==== Source: b ====
import "a" as Mod;
enum GlobalEnum { Red, Blue }

library Lib {
    enum LibraryEnum { Red, Blue }
}

contract C {
    enum ContractEnum { Red, Blue }

    function f() public pure {
        Mod.A;
        GlobalEnum;
        C.ContractEnum;
        ContractEnum;
        Lib.LibraryEnum;
        Mod.ALib.LibraryEnum;
        GlobalEnum;
        ContractEnum;
    }
}
// ----
// Warning 6133: (b:191-196): Statement has no effect.
// Warning 6133: (b:206-216): Statement has no effect.
// Warning 6133: (b:226-240): Statement has no effect.
// Warning 6133: (b:250-262): Statement has no effect.
// Warning 6133: (b:272-287): Statement has no effect.
// Warning 6133: (b:297-317): Statement has no effect.
// Warning 6133: (b:327-337): Statement has no effect.
// Warning 6133: (b:347-359): Statement has no effect.
