contract A {
    function foo() public {}
}

contract C {
    A constant aConst = A(address(1));
    function () external public constant aFooPtr = aConst.foo;
}

contract T {
    C c = C(address(1));
    function () external returns(function () external) constant aFooPtrGetter1 = c.aFooPtr;
}
// ----
// TypeError 8349: (282-291): Initial value for constant variable has to be compile-time constant.
