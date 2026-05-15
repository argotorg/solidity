library L {
    function fooInternal() internal {}

    E constant eConst = E(address(1));
    function () external constant public fooPublicEConstPtr = eConst.fooPublic;
    function () external constant public fooExternalEConstPtr = eConst.fooExternal;
}

contract E {
    function fooPublic() public {}
    function fooExternal() external {}
}

contract C {
    function () internal constant fooInternalLibPtr = L.fooInternal;

    E constant eConst = E(address(1));
    function () external constant fooPublicExtConstPtr = eConst.fooPublic;
    function () external constant fooPublicExtConstPtrCopy = C.fooPublicExtConstPtr;
    function () external constant fooExternalExtConstPtr = eConst.fooExternal;
    function () external constant fooExternalExtConstPtrCopy = C.fooExternalExtConstPtr;

    function () external constant fooLibPublicEConstPtr = L.fooPublicEConstPtr;
    function () external constant fooLibExternalEConstPtr = L.fooExternalEConstPtr;

    function test() pure public {
        L.fooInternal;

        E.fooPublic;
        E.fooExternal;

        C.fooPublicExtConstPtr;
        C.fooExternalExtConstPtr;
    }
}
// ----
// Warning 6133: (1006-1019): Statement has no effect.
// Warning 6133: (1030-1041): Statement has no effect.
// Warning 6133: (1051-1064): Statement has no effect.
// Warning 6133: (1075-1097): Statement has no effect.
// Warning 6133: (1107-1131): Statement has no effect.
