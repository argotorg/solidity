library L {
    function fooLibInternal(C c) internal {}
    function fooLibExternal(C c) external {}
    function fooLibPublic(C c) public {}
}

using L for C;

contract C {
    function fooPublic() public {}
    function fooExternal() external {}
}

contract T {
    C constant cConst = C(address(1));
    function () external constant fooPublicConstPtr = cConst.fooPublic;
    function () external constant fooExternalConstPtr = cConst.fooExternal;

    function test() pure private {
        cConst.fooPublic;
        cConst.fooExternal;
        cConst.fooLibInternal;
        cConst.fooLibExternal;
        cConst.fooLibPublic;
    }
}
// ----
// Warning 6133: (496-512): Statement has no effect.
// Warning 6133: (522-540): Statement has no effect.
// Warning 6133: (550-571): Statement has no effect.
// Warning 6133: (581-602): Statement has no effect.
// Warning 6133: (612-631): Statement has no effect.
