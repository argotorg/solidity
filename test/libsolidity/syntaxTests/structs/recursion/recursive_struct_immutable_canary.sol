// If this starts compiling, the copy tests need a variant
contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node immutable root;
}
// ----
// TypeError 6377: (151-170): Immutable variables cannot have a non-value type.
