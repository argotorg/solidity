==== Source: A.sol ====
contract A {
    enum EnumInA {
        VALUE,
        VALUE2,
        VALUE3,
        VALUE4
    }
}

==== Source: B.sol ====
import "A.sol";

contract B {
    struct S {
        uint256 y;
        A.EnumInA enumValue;
    }

    function t() public pure returns (bool) {
        return type(S).typehash == keccak256("S(uint256 y,uint8 enumValue)");
    }
}
// ----
// t() -> true