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

abstract contract A { uint256 public x = 1; }
abstract contract B is A {}
contract C is B {
    function f() public pure returns (uint256) {
        uint256 x = 99;
        return x;
    }
}
// ----
// Warning 2519: (155-168): This declaration shadows an existing declaration.
// Warning 2519: (373-388): This declaration shadows an existing declaration.
// Warning 2519: (576-585): This declaration shadows an existing declaration.
