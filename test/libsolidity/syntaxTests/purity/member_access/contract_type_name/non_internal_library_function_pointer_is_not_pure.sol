library L {
    function fooPublic() public {}
    function fooExternal() external {}
}

contract C {
    function () external constant fooPublicLibPtr = L.fooPublic;
    function () external constant fooExternalLibPtr = L.fooExternal;
}
// ----
// TypeError 7407: (154-165): Type function () is not implicitly convertible to expected type function () external. Special functions cannot be converted to function types.
// TypeError 8349: (154-165): Initial value for constant variable has to be compile-time constant.
// TypeError 7407: (221-234): Type function () is not implicitly convertible to expected type function () external. Special functions cannot be converted to function types.
// TypeError 8349: (221-234): Initial value for constant variable has to be compile-time constant.
