==== Source: a ====
struct A { uint x; }

library ALib {
    struct LibraryStruct { uint x; }
}

==== Source: b ====
import "a" as Mod;
struct GlobalStruct { uint x; }

library Lib {
    struct LibraryStruct { uint x; }
}

contract C {
    struct ContractStruct { uint x; }

    function f() public pure {
        Mod.A;
        GlobalStruct;
        C.ContractStruct;
        ContractStruct;
        Lib.LibraryStruct;
        Mod.ALib.LibraryStruct;
        GlobalStruct;
        ContractStruct;
    }
}
// ----
// Warning 6133: (b:197-202): Statement has no effect.
// Warning 6133: (b:212-224): Statement has no effect.
// Warning 6133: (b:234-250): Statement has no effect.
// Warning 6133: (b:260-274): Statement has no effect.
// Warning 6133: (b:284-301): Statement has no effect.
// Warning 6133: (b:311-333): Statement has no effect.
// Warning 6133: (b:343-355): Statement has no effect.
// Warning 6133: (b:365-379): Statement has no effect.
