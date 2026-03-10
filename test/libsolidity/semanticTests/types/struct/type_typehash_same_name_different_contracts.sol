==== Source: A.sol ====
contract A {
    struct S {
        uint256 x;
    }
}

==== Source: B.sol ====
import "A.sol";

contract B {
    struct S {
        A.S nested;
        uint256 y;
    }

    function testLocalHash() public pure returns (bool) {
        // B.S should encode as "S(S nested,uint256 y)S(uint256 x)"
        // This tests whether the nested struct name is properly handled
        return type(S).typehash == keccak256("S(S nested,uint256 y)S(uint256 x)");
    }

    function testImportedHash() public pure returns (bool) {
        // A.S should encode as "S(uint256 x)"
        return type(A.S).typehash == keccak256("S(uint256 x)");
    }
}
// ----
// testLocalHash() -> true
// testImportedHash() -> true