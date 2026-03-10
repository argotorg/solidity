==== Source: A.sol ====
struct S {
    uint256 x;
}

==== Source: B.sol ====
import {S as T} from "A.sol";

struct S {
    T t;
    uint256 y;
}

contract Test {
    function testImportedStructHash() public pure returns (bool) {
        // T (which is A.S) should hash as "S(uint256 x)" to use original definition
        return type(T).typehash == keccak256("S(uint256 x)");
    }

    function testLocalStructHash() public pure returns (bool) {
        // Local S contains T (alias for A.S), so it should hash as "S(S t,uint256 y)S(uint256 x)"
        return type(S).typehash == keccak256("S(S t,uint256 y)S(uint256 x)");
    }
}
// ----
// testImportedStructHash() -> true
// testLocalStructHash() -> true