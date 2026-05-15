contract A {
    function foo() public {}
}

contract C {
    uint256 public value = 0;
    uint256 public constant constValue = 0;

    function foo() external {}
    function () external public fooPtr = this.foo;

    A constant aConst = A(address(1));
    function () external public constant aFooPtr = aConst.foo;
}

contract T {
    C constant cConst = C(address(1));
    function () external returns(uint256) constant valueGetterConstPtr = cConst.value;
    function () external returns(uint256) constant constValueGetterConstPtr = cConst.constValue;
    function () external returns(function () external) constant fooPtrGetter = cConst.fooPtr;
    function () external returns(function () external) constant aFooPtrGetter = cConst.aFooPtr;

    function test() pure private {
        // FIX: "Function declared as pure, but this expression (potentially) reads from the environment or state and
        // thus requires "view"." This is not a call of a function but only a function pointer. In case when `cConst` is
        // constant is should be pure, similar to `cConst.constValue;`. It is properly marked as pure in `TypeChecker`
        // (see warning below), but the `ViewPureChecker` mask this as view, but ir does not read the state. Only
        // calling of this function would read the state.
        // cConst.value;
        // cConst.fooPtr;
        cConst.constValue;
        cConst.aFooPtr;
    }

    function testView() view private {
        cConst.value;
        cConst.fooPtr;
    }
}
// ----
// Warning 6133: (1372-1389): Statement has no effect.
// Warning 6133: (1399-1413): Statement has no effect.
// Warning 6133: (1469-1481): Statement has no effect.
// Warning 6133: (1491-1504): Statement has no effect.
