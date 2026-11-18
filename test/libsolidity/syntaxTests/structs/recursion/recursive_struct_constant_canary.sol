// If this starts compiling, the copy tests need a variant
contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node constant root = Node(new Node[](0), 0);
}
// ----
// TypeError 9259: (151-194): Only constants of value type and byte array type are implemented.
