contract C {
    struct Left {
        Right[] right;
    }


    struct Right {
        Left left;
    }

    function g() public pure returns (bool) {
        return type(Right).typehash == keccak256("Right(Left left)Left(Right[] right)");
    }

    function f() public pure returns (bool) {
        return type(Left).typehash == keccak256("Left(Right[] right)Right(Left left)");
    }
}
// ----
// g() -> true
// f() -> true