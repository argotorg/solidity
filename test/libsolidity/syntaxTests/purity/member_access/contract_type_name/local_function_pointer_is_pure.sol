contract E {
    function fooPublic() public {}
    function fooExternal() external {}
}

contract B {
    function fooBasePublic() public {}
    function fooBaseExternal() external {}
    function fooBaseInternal() internal {}

    E constant eConst = E(address(1));
    function () external constant public fooPublicEConstPtr = eConst.fooPublic;
    function () external constant public fooExternalEConstPtr = eConst.fooExternal;
}

contract C is B {
    function () internal constant fooPublicPtr = C.fooPublic;
    function () internal constant fooInternalPtr = C.fooInternal;

    function () external constant fooBPublicEConstPtrCopy = C.fooBPublicEConstPtr;

    function () internal constant fooBasePublicPtr = B.fooBasePublic;
    function () internal constant fooBaseInternalPtr = B.fooBaseInternal;

    function () external constant fooBPublicEConstPtr = B.fooPublicEConstPtr;
    function () external constant fooBExternalEConstPtr = B.fooExternalEConstPtr;

    function fooPublic() public {}
    function fooExternal() external {}
    function fooInternal() internal {}

    function test() pure public {
        C.fooPublic;
        C.fooExternal;
        C.fooInternal;

        C.fooBPublicEConstPtr;

        B.fooBasePublic;
        B.fooBaseExternal;
        B.fooBaseInternal;

        B.fooPublicEConstPtr;
        B.fooExternalEConstPtr;
    }
}
// ----
// Warning 6133: (1128-1139): Statement has no effect.
// Warning 6133: (1149-1162): Statement has no effect.
// Warning 6133: (1172-1185): Statement has no effect.
// Warning 6133: (1196-1217): Statement has no effect.
// Warning 6133: (1228-1243): Statement has no effect.
// Warning 6133: (1253-1270): Statement has no effect.
// Warning 6133: (1280-1297): Statement has no effect.
// Warning 6133: (1308-1328): Statement has no effect.
// Warning 6133: (1338-1360): Statement has no effect.
