==== Source: a ====
function fooA () {}

library ALib {
    function fooALibInternal () internal {}
    function fooALibPublic () public {}
    function fooALibExternal () external {}
}

==== Source: b ====
import "a" as Mod;
function foo () {}

library Lib {
    function fooLibInternal () internal {}
    function fooLibPublic () public {}
    function fooLibExternal () external {}
}

contract B {
    function fooBaseInternal() internal {}
    function fooBasePublic() public {}
    function fooBaseExternal() external {}
}

contract C is B {
    function fooContractPrivate () private {}
    function fooContractPublic () public {}

    function f() public pure {
        Mod.fooA;
        fooContractPublic;  // FIXME: This should generate warning too.
        fooContractPrivate; // FIXME: This should generate warning too.
        C.fooContractPublic;
        B.fooBaseInternal;
        B.fooBasePublic;
        B.fooBaseExternal;
        Lib.fooLibInternal;
        Mod.ALib.fooALibInternal;

        // TODO: Below functions use external call (delegate call). They need to access the state. They are not pure.
        // TODO: On the other hand they can be referenced in `pure` function.
        Lib.fooLibPublic;
        Lib.fooLibExternal;
        Mod.ALib.fooALibPublic;
        Mod.ALib.fooALibExternal;
    }
}
// ----
// Warning 6133: (b:470-478): Statement has no effect.
// Warning 6133: (b:632-651): Statement has no effect.
// Warning 6133: (b:661-678): Statement has no effect.
// Warning 6133: (b:688-703): Statement has no effect.
// Warning 6133: (b:713-730): Statement has no effect.
// Warning 6133: (b:740-758): Statement has no effect.
// Warning 6133: (b:768-792): Statement has no effect.
