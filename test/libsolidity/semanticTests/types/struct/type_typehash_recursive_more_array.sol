contract C {

    struct Left {
        Down[] down;
        Right[] right;
        Up[] up;
    }

    struct Right {
        Down[] down;
        Left[] left;
        Up[] up;
    }

    struct Up {
        Down[] down;
        Left[] left;
        Right[] right;
    }
    struct Down {
        Up[] up;
        Left[] left;
        Right[] right;
    }

    // first element and alphabetical order of structs. Down -> Left -> Right -> Up.
    function g() public pure returns (bool) {
        return type(Right).typehash == keccak256("Right(Down[] down,Left[] left,Up[] up)Down(Up[] up,Left[] left,Right[] right)Left(Down[] down,Right[] right,Up[] up)Up(Down[] down,Left[] left,Right[] right)");
    }

    function f() public pure returns (bool) {
        return type(Left).typehash == keccak256("Left(Down[] down,Right[] right,Up[] up)Down(Up[] up,Left[] left,Right[] right)Right(Down[] down,Left[] left,Up[] up)Up(Down[] down,Left[] left,Right[] right)");
    }

    function h() public pure returns (bool) {
        return type(Up).typehash == keccak256("Up(Down[] down,Left[] left,Right[] right)Down(Up[] up,Left[] left,Right[] right)Left(Down[] down,Right[] right,Up[] up)Right(Down[] down,Left[] left,Up[] up)");
    }
    function i() public pure returns (bool) {
        return type(Down).typehash == keccak256("Down(Up[] up,Left[] left,Right[] right)Left(Down[] down,Right[] right,Up[] up)Right(Down[] down,Left[] left,Up[] up)Up(Down[] down,Left[] left,Right[] right)");
    }
}
// ----
// g() -> true
// f() -> true
// h() -> true
// i() -> true