
contract C {

    struct Left {
        Right[] right;
    }

    struct Right {
        Left left;
    }

    bytes32 h = type(Left).typehash;
    bytes32 h2 = type(Right).typehash;
}
// ----
