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
    C constant cConst = C(address(0x886677));
    function () external constant public fooPublicConstPtr = cConst.fooPublic;
    function () external constant public fooExternalConstPtr = cConst.fooExternal;

    function test() public {
        require(C.fooPublic.selector == fooPublicConstPtr.selector);
        require(cConst.fooPublic.selector == fooPublicConstPtr.selector);
        require(cConst.fooPublic.address == fooPublicConstPtr.address);

        require(C.fooExternal.selector == fooExternalConstPtr.selector);
        require(cConst.fooExternal.selector == fooExternalConstPtr.selector);
        require(cConst.fooExternal.address == fooExternalConstPtr.address);
    }

    function testLibFunction() pure public {
        require(cConst.fooLibExternal.selector == L.fooLibExternal.selector);
        require(cConst.fooLibPublic.selector == L.fooLibPublic.selector);
    }
}
// ----
// library: L
// test() ->
// testLibFunction() ->
// fooPublicConstPtr() -> 0x886677d08ff2e70000000000000000
// fooExternalConstPtr() -> 0x8866773bebdd5a0000000000000000
