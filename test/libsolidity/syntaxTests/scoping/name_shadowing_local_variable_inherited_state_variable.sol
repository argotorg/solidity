contract ConcreteBase {
    uint256 public value = 10;
}
contract ChildConcrete is ConcreteBase {
    function f() public pure returns (uint256) {
        uint256 value = 99;
        return value;
    }
}

abstract contract AbstractBase {
    uint256 public balance = 100;
}
contract ChildAbstract is AbstractBase {
    function f() public pure returns (uint256) {
        uint256 balance = 0;
        return balance;
    }
}
// ----
// Warning 2519: (155-168): This declaration shadows an existing declaration.
// Warning 2519: (373-388): This declaration shadows an existing declaration.
